# Dashboard-Server: liefert die Oberfläche und eine kleine JSON-API.
#   Normalbetrieb: start-hub.cmd  ·  Adresse: http://localhost:8787/ (Port in config.json)
#
# Lauscht nur auf diesem PC (127.0.0.1 und ::1). Vom Handy kommt man über Tailscale Serve heran
# (https://<pc>.<tailnet>.ts.net:8443 → localhost:8787); dessen Hostname muss in config.json unter
# "dashboardHosts" stehen. Bewusst ein eigener kleiner HTTP-Server statt HttpListener: Der lässt ohne
# Admin-Freigabe nur den Hostnamen "localhost" zu.

. (Join-Path $PSScriptRoot 'common.ps1')
$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Web

if (-not (Enter-SingleInstance 'Server')) { Write-Host 'Der Dashboard-Server läuft bereits.'; exit 0 }

$cfg = Get-HubConfig
$port = [int]$cfg.port
$dashboardFile = Join-Path $PSScriptRoot 'dashboard\index.html'

# Nur Anfragen an diese Hostnamen beantworten. Schützt vor DNS-Rebinding: Eine fremde Webseite,
# deren Name kurzzeitig auf 127.0.0.1 zeigt, bekommt keine Antwort.
$script:AllowedHosts = @('localhost', '127.0.0.1', '[::1]') + @(@($cfg.dashboardHosts) | Where-Object { $_ } | ForEach-Object { "$_".ToLower() })

$listeners = @()
foreach ($address in @([System.Net.IPAddress]::Loopback, [System.Net.IPAddress]::IPv6Loopback)) {
    try {
        $l = New-Object System.Net.Sockets.TcpListener($address, $port)
        $l.Start()
        $listeners += $l
    } catch { }
}
if ($listeners.Count -eq 0) { Add-HubLog "Dashboard: Port $port ist belegt, Server nicht gestartet"; exit 1 }
Write-Text (Get-HubPath 'state\server.pid') "$PID"

## Liest eine HTTP-Anfrage: Kopfzeilen und, falls Content-Length gesetzt ist, den Körper (höchstens 64 KB, als UTF-8-Text).
function Read-HttpRequest($Client) {
    $stream = $Client.GetStream()
    $stream.ReadTimeout = 5000
    $buffer = New-Object byte[] 8192
    $data = New-Object System.IO.MemoryStream
    $text = ''
    $headerEnd = -1
    while ($headerEnd -lt 0 -and $data.Length -lt 65536) {
        $n = $stream.Read($buffer, 0, $buffer.Length)
        if ($n -le 0) { break }
        $data.Write($buffer, 0, $n)
        $text = [Text.Encoding]::ASCII.GetString($data.GetBuffer(), 0, [int]$data.Length)
        $headerEnd = $text.IndexOf("`r`n`r`n")
    }
    if ($headerEnd -lt 0) { return $null }
    $lines = $text.Substring(0, $headerEnd) -split "`r`n"
    $parts = $lines[0] -split ' '
    if ($parts.Count -lt 3 -or -not $parts[1].StartsWith('/')) { return $null }
    $headers = New-Object System.Collections.Specialized.NameValueCollection
    foreach ($line in ($lines | Select-Object -Skip 1)) {
        $i = $line.IndexOf(':')
        if ($i -gt 0) { $headers.Add($line.Substring(0, $i).Trim(), $line.Substring($i + 1).Trim()) }
    }
    $uri = [Uri]("http://localhost" + $parts[1])
    $body = ''
    $length = 0
    if ([int]::TryParse("$($headers['Content-Length'])", [ref]$length) -and $length -gt 0 -and $length -le 65536) {
        $start = $headerEnd + 4
        while ($data.Length - $start -lt $length) {
            $n = $stream.Read($buffer, 0, $buffer.Length)
            if ($n -le 0) { break }
            $data.Write($buffer, 0, $n)
        }
        $available = [Math]::Min($length, [int]$data.Length - $start)
        if ($available -gt 0) { $body = [Text.Encoding]::UTF8.GetString($data.GetBuffer(), $start, $available) }
    }
    [pscustomobject]@{
        HttpMethod  = $parts[0].ToUpper()
        Url         = $uri
        QueryString = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
        Headers     = $headers
        Body        = $body
    }
}

function New-HttpResponse {
    [pscustomobject]@{
        StatusCode = 200; ContentType = 'text/plain; charset=utf-8'; ContentLength64 = 0
        Headers = (New-Object System.Collections.Specialized.NameValueCollection)
        OutputStream = (New-Object System.IO.MemoryStream)
    }
}

function Write-HttpResponse($Client, $Response) {
    $body = $Response.OutputStream.ToArray()
    $reason = switch ($Response.StatusCode) {
        200 { 'OK' } 400 { 'Bad Request' } 403 { 'Forbidden' } 404 { 'Not Found' }
        405 { 'Method Not Allowed' } 409 { 'Conflict' } default { 'Internal Server Error' }
    }
    $head = "HTTP/1.1 $($Response.StatusCode) $reason`r`nContent-Type: $($Response.ContentType)`r`nContent-Length: $($body.Length)`r`n"
    foreach ($key in $Response.Headers.AllKeys) { $head += "${key}: $($Response.Headers[$key])`r`n" }
    $head += "Connection: close`r`n`r`n"
    $stream = $Client.GetStream()
    $bytes = [Text.Encoding]::ASCII.GetBytes($head)
    $stream.Write($bytes, 0, $bytes.Length)
    if ($body.Length -gt 0) { $stream.Write($body, 0, $body.Length) }
    $stream.Flush()
}

$script:OllamaCache = $null
$script:OllamaCacheTime = [datetime]::MinValue

function Send-Text($Context, [int]$Code, [string]$ContentType, [string]$Text) {
    $bytes = $script:Utf8NoBom.GetBytes($Text)
    $res = $Context.Response
    $res.StatusCode = $Code
    $res.ContentType = "$ContentType; charset=utf-8"
    $res.Headers.Add('Cache-Control', 'no-store')
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
}

function Send-Json($Context, [int]$Code, $Object) {
    Send-Text $Context $Code 'application/json' (ConvertTo-Json -InputObject $Object -Depth 8 -Compress)
}

function Send-Bytes($Context, [int]$Code, [string]$ContentType, [byte[]]$Bytes) {
    $res = $Context.Response
    $res.StatusCode = $Code
    $res.ContentType = $ContentType
    $res.Headers.Add('Cache-Control', 'max-age=60')
    $res.ContentLength64 = $Bytes.Length
    $res.OutputStream.Write($Bytes, 0, $Bytes.Length)
}

## Offene Punkte mit Inhalt und Bildern für den Seitenbereich (Klick auf die Punkte-Kacheln).
function Get-PunkteDetail([string[]]$Status) {
    $dir = Get-HubPath 'lastenhefte\punkte'
    @(Get-Punkte | Where-Object { $Status -contains $_.Status } | Sort-Object Id | ForEach-Object {
        $body = (Split-FrontMatter (Read-Text (Join-Path $dir $_.File))).Body
        $material = Join-Path $dir $_.Id
        $bilder = @()
        if (Test-Path -LiteralPath $material) {
            $bilder = @(Get-ChildItem -LiteralPath $material -File | Where-Object { $_.Extension -match '^\.(png|jpe?g|webp|gif)$' } |
                Sort-Object Name | ForEach-Object { $_.Name })
        }
        [ordered]@{
            id = $_.Id; title = $_.Title; kind = $_.Kind; status = $_.Status
            projects = @($_.Projects); file = $_.File; body = $body; bilder = $bilder
        }
    })
}

function Get-OllamaStatus {
    if (((Get-Date) - $script:OllamaCacheTime).TotalSeconds -lt 5) { return $script:OllamaCache }
    $result = [ordered]@{ reachable = $false; models = @() }
    try {
        $ps = Invoke-RestMethod -Uri "$($cfg.ollamaUrl)/api/ps" -TimeoutSec 2
        $result.reachable = $true
        if ($ps.models) {
            $result.models = @($ps.models | ForEach-Object {
                $gpu = 0
                if ($_.size -gt 0) { $gpu = [math]::Round(100 * $_.size_vram / $_.size) }
                [ordered]@{ name = $_.name; sizeGB = [math]::Round($_.size / 1GB, 1); gpuPercent = $gpu }
            })
        }
    } catch { }
    $script:OllamaCache = $result
    $script:OllamaCacheTime = Get-Date
    return $result
}

function Get-TicketSummary($Ticket, $ReadyIds) {
    $st = Read-JsonCached (Join-Path (Get-RunDir $Ticket.Id) 'status.json')
    $attempts = 0; $runState = $null; $warnings = 0; $message = $null
    if ($st) {
        if ($st.attempts) { $attempts = @($st.attempts).Count }
        if ($st.warnings) { $warnings = @($st.warnings).Count }
        $runState = $st.state
        $message = $st.message
    }
    [ordered]@{
        id = $Ticket.Id; title = $Ticket.Title; project = $Ticket.Project; priority = $Ticket.Priority
        after = $Ticket.After; waitingFor = (@(Get-AfterIds $Ticket | Where-Object { $ReadyIds -notcontains $_ }) -join ', ')
        modified = $Ticket.Modified.ToString('o'); attempts = $attempts; runState = $runState
        warnings = $warnings; message = $message
    }
}

function Get-HubState {
    $worker = Read-Json (Get-HubPath 'state\worker.json')
    $alive = $false
    if ($worker -and (Get-ProcessAlive $worker.pid)) {
        try {
            $beat = $worker.heartbeat
            if (-not ($beat -is [datetime])) { $beat = [datetime]::Parse($beat) }
            $alive = ((Get-Date) - $beat).TotalSeconds -lt 120
        } catch { }
    }
    $columns = [ordered]@{}
    $readyIds = Get-ReadyIds
    foreach ($column in $script:Columns) {
        $list = @(Get-Tickets $column)
        if ($column -in @('todo', 'doing')) { $list = @($list | Sort-Object Priority, Id) }
        else { $list = @($list | Sort-Object Modified -Descending) }
        $total = $list.Count
        if ($column -eq 'done') { $list = @($list | Select-Object -First 40) }
        $columns[$column] = [ordered]@{ total = $total; items = @($list | ForEach-Object { Get-TicketSummary $_ $readyIds }) }
    }
    $review = $null
    $reviewFile = Get-ChildItem (Get-HubPath 'reviews') -Filter '*.md' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($reviewFile) {
        $text = Read-Text $reviewFile.FullName
        if ($text.Length -gt 6000) { $text = $text.Substring(0, 6000) }
        $review = [ordered]@{ file = $reviewFile.Name; modified = $reviewFile.LastWriteTime.ToString('o'); text = $text }
    }
    # Bewusst nicht Get-Content: Dessen Zeilen tragen PSPath/PSDrive-Eigenschaften,
    # die ConvertTo-Json in PowerShell 5.1 endlos tief mitserialisiert.
    $log = @()
    $logText = Read-Text (Get-HubPath 'state\worker.log')
    if ($logText) { $log = @($logText -split '\r?\n' | Where-Object { $_ } | Select-Object -Last 40) }
    [ordered]@{
        now = Get-Now; worker = $worker; workerAlive = $alive
        paused = (Test-Path -LiteralPath (Get-HubPath 'state\paused'))
        ollama = Get-OllamaStatus; columns = $columns; review = $review; log = $log
        kennzahlen = Get-Kennzahlen
    }
}

$script:KennzahlenCache = $null
$script:KennzahlenZeit = [datetime]::MinValue

## Kennzahlen für die Leiste im Board: Auslastung der letzten 24 Stunden, offene Punkte,
## Higgsfield-Credits (schreibt der Review nach state\higgsfield.json) und letzte Sicherung.
## Höchstens einmal pro Minute neu berechnet.
function Get-Kennzahlen {
    if ($script:KennzahlenCache -and ((Get-Date) - $script:KennzahlenZeit).TotalSeconds -lt 60) { return $script:KennzahlenCache }
    $dayAgo = (Get-Date).AddHours(-24)
    $busy = 0.0; $passed = 0; $failed = 0
    foreach ($dir in @(Get-ChildItem (Get-HubPath 'runs') -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^T-\d+$' })) {
        $st = Read-JsonCached (Join-Path $dir.FullName 'status.json')
        if (-not $st -or -not $st.started) { continue }
        try {
            $start = [datetime]::Parse("$($st.started)")
            $end = if ($st.finished) { [datetime]::Parse("$($st.finished)") } else { Get-Date }
        } catch { continue }
        if ($end -lt $dayAgo) { continue }
        if ($start -lt $dayAgo) { $start = $dayAgo }
        $busy += ($end - $start).TotalMinutes
        if ($st.finished -and $st.state -eq 'passed') { $passed++ } elseif ($st.finished -and $st.state -eq 'failed') { $failed++ }
    }
    $punkte = @(Get-Punkte)
    $script:KennzahlenCache = [ordered]@{
        auslastung = [math]::Min(100, [math]::Round(100 * $busy / 1440))
        bestanden24h = $passed; fehlgeschlagen24h = $failed
        punkteChatGpt = @($punkte | Where-Object { $_.Status -eq 'offen' }).Count
        punkteNutzer = @($punkte | Where-Object { $_.Status -eq 'weitergegeben' }).Count
        punkteBeantwortet = @($punkte | Where-Object { $_.Status -eq 'beantwortet' }).Count
        higgsfield = Read-Json (Get-HubPath 'state\higgsfield.json')
        sicherung = Read-Json (Get-HubPath 'state\last-backup.json')
    }
    $script:KennzahlenZeit = Get-Date
    return $script:KennzahlenCache
}

function Get-TicketDetail([string]$Id) {
    $ticket = Find-Ticket $Id
    if (-not $ticket) { return $null }
    $runDir = Get-RunDir $Id
    $files = @()
    if (Test-Path -LiteralPath $runDir) {
        $files = @(Get-ChildItem -LiteralPath $runDir -File | Where-Object { $_.Name -notmatch '^status\.json|\.tmp$' } |
            Sort-Object Name | ForEach-Object { [ordered]@{ name = $_.Name; size = $_.Length } })
    }
    [ordered]@{
        id = $ticket.Id; title = $ticket.Title; project = $ticket.Project; priority = $ticket.Priority
        model = $ticket.Model; verify = $ticket.Verify; column = $ticket.Column
        modified = $ticket.Modified.ToString('o'); body = $ticket.Body
        status = Read-Json (Join-Path $runDir 'status.json')
        report = Read-Text (Join-Path $runDir 'report.md')
        files = $files
    }
}

## Alle Ablaufpläne (plans/<projekt>.json) für die Auswahl im Dashboard.
function Get-PlanList {
    $dir = Get-HubPath 'plans'
    if (-not (Test-Path -LiteralPath $dir)) { return @() }
    return @(Get-ChildItem -LiteralPath $dir -Filter '*.json' -File | ForEach-Object {
        $plan = Read-Json $_.FullName
        # "visible": false = im Lastenheft "ablaufplan: nein"; der Plan dient dann nur intern.
        if ($plan -and $plan.visible -ne $false) { [ordered]@{ project = $plan.project; title = $plan.title } }
    })
}

## Projektwarteschlange: alle Lastenhefte mit Status, Fragen, Fortschritt und anstehenden Aufgaben.
function Get-ProjectsOverview {
    $order = @($script:ProjectStates.Keys)
    $worker = Read-Json (Get-HubPath 'state\worker.json')
    $specs = @(Get-Lastenhefte | Sort-Object @{ Expression = { $order.IndexOf($_.Status) } }, Priority, Created, Name)
    $punkte = @(Get-Punkte | Where-Object { @('offen', 'weitergegeben', 'beantwortet') -contains $_.Status } | Sort-Object Id)
    $items = @($specs | ForEach-Object {
        $spec = $_
        $progress = Get-PlanProgress $spec.Name
        $summary = $null
        $tasks = @(); $userTasks = @()
        if ($progress) {
            $summary = [ordered]@{
                done = $progress.Done; total = $progress.Total; visible = $progress.Visible
                milestonesDone = $progress.MilestonesDone; milestones = $progress.Milestones
            }
            $tasks = @($progress.ReadyTasks)
            $userTasks = @($progress.UserTasks)
        }
        $own = @($punkte | Where-Object { $_.Projects -contains $spec.Name } | ForEach-Object {
            [ordered]@{ id = $_.Id; title = $_.Title; kind = $_.Kind; status = $_.Status }
        })
        [ordered]@{
            name = $spec.Name; title = $spec.Title; status = $spec.Status; statusLabel = $script:ProjectStates[$spec.Status]
            priority = $spec.Priority; created = $spec.Created; file = $spec.File; modified = $spec.Modified.ToString('o')
            newFeedback = $spec.NewFeedback; progress = $summary; tasks = $tasks; userTasks = $userTasks; punkte = $own
            working = [bool]($worker -and $worker.state -eq 'working' -and $worker.project -eq $spec.Name)
        }
    })
    return [ordered]@{ projects = $items }
}

## Ein Ablaufplan plus alle Tickets des Projekts. Status, Fortschritt und
## Abhängigkeiten berechnet das Dashboard daraus selbst.
function Get-PlanDetail([string]$Project) {
    $plan = Read-Json (Get-HubPath "plans\$Project.json")
    if (-not $plan) { return $null }
    $tickets = @()
    foreach ($column in $script:Columns) {
        foreach ($ticket in @(Get-Tickets $column)) {
            if ($ticket.Project -ne $Project) { continue }
            $st = Read-JsonCached (Join-Path (Get-RunDir $ticket.Id) 'status.json')
            $attempts = 0
            if ($st -and $st.attempts) { $attempts = @($st.attempts).Count }
            $tickets += [ordered]@{
                id = $ticket.Id; title = $ticket.Title; column = $column; after = @(Get-AfterIds $ticket)
                priority = $ticket.Priority; attempts = $attempts; modified = $ticket.Modified.ToString('o')
            }
        }
    }
    return [ordered]@{ plan = $plan; tickets = $tickets; stats = (Get-PlanStats $Project) }
}

## Kennzahlen für die Prognose im Ablaufplan: gemessene Dauer pro Ticket (über alle
## Projekte), Review-Zeiten aus config.json und was der Worker gerade tut.
function Get-PlanStats([string]$Project) {
    $cfg = Get-HubConfig
    $minutes = @()
    foreach ($column in @('review', 'failed', 'done')) {
        foreach ($ticket in @(Get-Tickets $column)) {
            $st = Read-JsonCached (Join-Path (Get-RunDir $ticket.Id) 'status.json')
            if (-not $st -or -not $st.started -or -not $st.finished) { continue }
            try { $minutes += ([datetime]::Parse($st.finished) - [datetime]::Parse($st.started)).TotalMinutes } catch { }
        }
    }
    $avg = 5.0
    if ($minutes.Count -gt 0) { $avg = ($minutes | Measure-Object -Average).Average }
    $worker = Read-Json (Get-HubPath 'state\worker.json')
    return [ordered]@{
        avgTicketMinutes  = [math]::Round($avg, 1)
        measuredTickets   = $minutes.Count
        reviewTimes       = @($cfg.reviewTimes)
        reviewMinutes     = [int]$cfg.reviewMinutes
        queueAhead        = @(Get-Tickets 'todo' | Where-Object { $_.Project -ne $Project }).Count
        workerTicket      = $worker.ticket
        workerTicketSince = $worker.ticketSince
    }
}

## Beantwortet eine Anfrage; $Context hat Request und Response wie bei HttpListener.
function Invoke-Route($Context) {
        $ctx = $Context
        $req = $ctx.Request
        $path = $req.Url.AbsolutePath
        $id = $req.QueryString['id']
        if ($id -and $id -notmatch $script:IdPattern) {
            Send-Text $ctx 400 'text/plain' 'Ungültige Ticket-ID'
        } elseif ($req.HttpMethod -eq 'GET') {
            if ($path -eq '/' -or $path -eq '/index.html') {
                Send-Text $ctx 200 'text/html' ([IO.File]::ReadAllText($dashboardFile, [Text.Encoding]::UTF8))
            } elseif ($path -eq '/api/state') {
                Send-Json $ctx 200 (Get-HubState)
            } elseif ($path -eq '/api/projects') {
                Send-Json $ctx 200 (Get-ProjectsOverview)
            } elseif ($path -eq '/api/lastenheft') {
                $name = $req.QueryString['file']
                $file = $null
                if ($name -match '^[\w.\-]+\.md$') { $file = Join-Path (Get-HubPath 'lastenhefte') $name }
                if ($file -and (Test-Path -LiteralPath $file)) {
                    Send-Text $ctx 200 'text/plain' (Read-Text $file)
                } else {
                    Send-Text $ctx 404 'text/plain' 'Lastenheft nicht gefunden'
                }
            } elseif ($path -eq '/api/punkte') {
                $status = @("$($req.QueryString['status'])" -split ',' | Where-Object { $_ -match '^(offen|beantwortet|weitergegeben)$' })
                if ($status.Count -eq 0) { $status = @('offen', 'beantwortet', 'weitergegeben') }
                Send-Json $ctx 200 @(Get-PunkteDetail $status)
            } elseif ($path -eq '/api/punkt-bild') {
                $punktId = "$($req.QueryString['punkt'])"
                $name = "$($req.QueryString['name'])"
                $file = $null
                if ($punktId -match '^P-\d{4,6}$' -and $name -match '^[\w.\-]+\.(png|jpe?g|webp|gif)$') {
                    $file = Join-Path (Get-HubPath "lastenhefte\punkte\$punktId") $name
                }
                if ($file -and (Test-Path -LiteralPath $file)) {
                    $type = switch -Regex ($name) { '\.png$' { 'image/png' } '\.jpe?g$' { 'image/jpeg' } '\.webp$' { 'image/webp' } default { 'image/gif' } }
                    Send-Bytes $ctx 200 $type ([IO.File]::ReadAllBytes($file))
                } else {
                    Send-Text $ctx 404 'text/plain' 'Bild nicht gefunden'
                }
            } elseif ($path -eq '/api/plans') {
                Send-Json $ctx 200 @(Get-PlanList)
            } elseif ($path -eq '/api/plan') {
                $project = $req.QueryString['project']
                $detail = $null
                if ($project -match '^[\w-]+$') { $detail = Get-PlanDetail $project }
                if ($detail) { Send-Json $ctx 200 $detail } else { Send-Text $ctx 404 'text/plain' 'Ablaufplan nicht gefunden' }
            } elseif ($path -eq '/api/ticket') {
                $detail = Get-TicketDetail $id
                if ($detail) { Send-Json $ctx 200 $detail } else { Send-Text $ctx 404 'text/plain' 'Ticket nicht gefunden' }
            } elseif ($path -eq '/api/file') {
                $name = $req.QueryString['name']
                $file = $null
                if ($id -and $name -match '^[\w.\-]+$') { $file = Join-Path (Get-RunDir $id) $name }
                if ($file -and (Test-Path -LiteralPath $file)) {
                    $text = Read-Text $file
                    if ($text.Length -gt 400000) { $text = "… (gekürzt, nur das Ende)`n" + $text.Substring($text.Length - 400000) }
                    Send-Text $ctx 200 'text/plain' $text
                } else {
                    Send-Text $ctx 404 'text/plain' 'Datei nicht gefunden'
                }
            } else {
                Send-Text $ctx 404 'text/plain' 'Nicht gefunden'
            }
        } elseif ($req.HttpMethod -eq 'POST') {
            # Eigener Header: Fremde Webseiten können ihn nicht setzen, ohne am CORS-Check zu scheitern.
            if ($req.Headers['X-Hub'] -ne '1') {
                Send-Text $ctx 403 'text/plain' 'Verboten'
            } elseif ($path -eq '/api/punkt-antwort') {
                # Antwort des Nutzers auf einen weitergegebenen Punkt (vom Handy oder PC); Körper: {"id": "P-0012", "text": "…"}
                $answer = $null
                try { $answer = $req.Body | ConvertFrom-Json } catch { }
                $fehler = if ($answer) { Set-PunktAntwort "$($answer.id)" "$($answer.text)" } else { 'Ungültige Anfrage' }
                if ($fehler) { Send-Text $ctx 400 'text/plain' $fehler } else { Send-Json $ctx 200 @{ ok = $true } }
            } elseif ($path -eq '/api/pause') {
                Write-Text (Get-HubPath 'state\paused') (Get-Now)
                Add-HubLog 'Worker pausiert (über das Dashboard)'
                Send-Json $ctx 200 @{ ok = $true }
            } elseif ($path -eq '/api/resume') {
                Remove-Item -LiteralPath (Get-HubPath 'state\paused') -Force -ErrorAction SilentlyContinue
                Add-HubLog 'Worker fortgesetzt (über das Dashboard)'
                Send-Json $ctx 200 @{ ok = $true }
            } elseif ($path -eq '/api/retry') {
                $ticket = Find-Ticket $id
                if ($ticket -and $ticket.Column -eq 'failed') {
                    Move-Ticket $ticket 'todo' | Out-Null
                    Add-HubLog "$id erneut eingeplant (über das Dashboard)"
                    Send-Json $ctx 200 @{ ok = $true }
                } else {
                    Send-Text $ctx 409 'text/plain' 'Nur fehlgeschlagene Tickets können erneut versucht werden.'
                }
            } else {
                Send-Text $ctx 404 'text/plain' 'Nicht gefunden'
            }
        } else {
            Send-Text $ctx 405 'text/plain' 'Methode nicht erlaubt'
        }
}

Add-HubLog "Dashboard gestartet: http://localhost:$port/ (zusätzlich erlaubt: $(@($cfg.dashboardHosts) -join ', '))"

while ($true) {
    $client = $null
    foreach ($l in $listeners) { if ($l.Pending()) { $client = $l.AcceptTcpClient(); break } }
    if (-not $client) { Start-Sleep -Milliseconds 15; continue }
    $ctx = [pscustomobject]@{ Request = $null; Response = (New-HttpResponse) }
    try {
        $ctx.Request = Read-HttpRequest $client
        if (-not $ctx.Request) {
            Send-Text $ctx 400 'text/plain' 'Ungültige Anfrage'
        } else {
            $hostName = ("$($ctx.Request.Headers['Host'])" -replace ':\d+$', '').ToLower()
            if ($script:AllowedHosts -notcontains $hostName) {
                Send-Text $ctx 403 'text/plain' 'Unbekannter Hostname'
            } else {
                Invoke-Route $ctx
            }
        }
    } catch {
        try { $ctx.Response = New-HttpResponse; Send-Json $ctx 500 @{ error = "$($_.Exception.Message)" } } catch { }
    } finally {
        try { Write-HttpResponse $client $ctx.Response } catch { }
        try { $client.Close() } catch { }
    }
}
