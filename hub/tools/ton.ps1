# Tonanalyse einer WAV-Datei (z. B. aus dem Filmlauf der Spieltests): Pegel, Spitzen, Übersteuerung,
# Stille und eine grobe Tonhöhe (Nulldurchgänge) je Zeitfenster. Ergebnis als Text für Claude bzw. ChatGPT;
# ob es gut klingt, beurteilt weiterhin der Nutzer.
#   powershell -NoProfile -ExecutionPolicy Bypass -File hub\tools\ton.ps1 -Wav <datei> [-Von 0] [-Bis 30] [-Fenster 1]
# Als Funktion (spieltest.ps1): . hub\tools\ton.ps1 -NurLaden; Get-TonAnalyse <datei> <von> <bis> <fenster>
param([string]$Wav = '', [double]$Von = 0, [double]$Bis = -1, [double]$Fenster = 1, [switch]$NurLaden)

if (-not ('AgentHub.TonAnalyse' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.IO;
namespace AgentHub {
    public class TonFenster {
        public double Zeit; public double PegelDb; public double SpitzeDb; public double TonhoeheHz; public double Uebersteuert;
    }
    public class TonErgebnis {
        public int Rate; public int Kanaele; public int Bits; public double Dauer;
        public double PegelDb; public double SpitzeDb; public double UebersteuertProzent; public double StilleProzent;
        public TonFenster[] Fenster;
    }
    public static class TonAnalyse {
        static double Db(double v) { return v <= 1e-9 ? -120.0 : 20.0 * Math.Log10(v); }

        public static TonErgebnis Analysiere(string pfad, double von, double bis, double fenster) {
            byte[] d = File.ReadAllBytes(pfad);
            if (d.Length < 44 || d[0] != 'R' || d[8] != 'W') throw new Exception("Keine WAV-Datei: " + pfad);
            int format = 1, kanaele = 2, rate = 44100, bits = 16; int datenStart = -1, datenLaenge = 0;
            int pos = 12;
            while (pos + 8 <= d.Length) {
                string id = System.Text.Encoding.ASCII.GetString(d, pos, 4);
                int len = BitConverter.ToInt32(d, pos + 4);
                if (id == "fmt ") {
                    format = BitConverter.ToInt16(d, pos + 8); kanaele = BitConverter.ToInt16(d, pos + 10);
                    rate = BitConverter.ToInt32(d, pos + 12); bits = BitConverter.ToInt16(d, pos + 22);
                    if (format == -2 && len >= 26) format = BitConverter.ToInt16(d, pos + 32); // WAVE_FORMAT_EXTENSIBLE
                } else if (id == "data") {
                    datenStart = pos + 8; datenLaenge = Math.Min(len < 0 ? int.MaxValue : len, d.Length - datenStart); break;
                }
                pos += 8 + len + (len % 2);
            }
            if (datenStart < 0) throw new Exception("WAV ohne Daten: " + pfad);
            int bytesProWert = bits / 8; int rahmen = bytesProWert * kanaele;
            long gesamt = datenLaenge / rahmen;
            double dauer = (double)gesamt / rate;
            long a = (long)(Math.Max(0, von) * rate);
            long b = bis < 0 ? gesamt : Math.Min(gesamt, (long)(bis * rate));
            int proFenster = Math.Max(1, (int)(fenster * rate));
            int anzahl = (int)Math.Max(0, (b - a + proFenster - 1) / proFenster);
            var liste = new TonFenster[anzahl];
            double sumQ = 0, spitze = 0; long ueber = 0, still = 0, n = 0;
            // Tonhöhe: Nulldurchgänge nach einem Tiefpass (Grundton von Motor, Summen usw., nicht Rauschen)
            // mit Hysterese, damit leises Rauschen keine Durchgänge zählt.
            double alpha = 1.0 - Math.Exp(-2.0 * Math.PI * 500.0 / rate), lp = 0;
            double[] puffer = new double[proFenster];
            for (int f = 0; f < anzahl; f++) {
                long s0 = a + (long)f * proFenster, s1 = Math.Min(b, s0 + proFenster);
                double q = 0, sp = 0, lq = 0; long nd = 0, ue = 0;
                for (long s = s0; s < s1; s++) {
                    double m = 0;
                    for (int k = 0; k < kanaele; k++) {
                        int o = datenStart + (int)(s * rahmen) + k * bytesProWert; double v;
                        if (format == 3 && bits == 32) v = BitConverter.ToSingle(d, o);
                        else if (bits == 16) v = BitConverter.ToInt16(d, o) / 32768.0;
                        else if (bits == 24) v = ((d[o] | (d[o + 1] << 8) | ((sbyte)d[o + 2] << 16))) / 8388608.0;
                        else if (bits == 32) v = BitConverter.ToInt32(d, o) / 2147483648.0;
                        else v = (d[o] - 128) / 128.0;
                        m += v;
                    }
                    m /= kanaele;
                    q += m * m; double am = Math.Abs(m); if (am > sp) sp = am; if (am >= 0.999) ue++;
                    lp += alpha * (m - lp); puffer[s - s0] = lp; lq += lp * lp;
                }
                long laenge = Math.Max(1, s1 - s0);
                double rms = Math.Sqrt(q / laenge);
                double schwelle = 0.25 * Math.Sqrt(lq / laenge); int zustand = 0;
                for (long i = 0; i < laenge; i++) {
                    double v = puffer[i];
                    if (v > schwelle && zustand <= 0) { if (zustand < 0) nd++; zustand = 1; }
                    else if (v < -schwelle && zustand >= 0) { if (zustand > 0) nd++; zustand = -1; }
                }
                var t = new TonFenster();
                t.Zeit = (double)s0 / rate; t.PegelDb = Db(rms); t.SpitzeDb = Db(sp);
                t.TonhoeheHz = rms < 0.003 ? 0 : nd / 2.0 / ((double)laenge / rate);
                t.Uebersteuert = 100.0 * ue / laenge;
                liste[f] = t;
                sumQ += q; n += laenge; ueber += ue; if (spitze < sp) spitze = sp; if (rms < 0.003) still += laenge;
            }
            var e = new TonErgebnis();
            e.Rate = rate; e.Kanaele = kanaele; e.Bits = bits; e.Dauer = dauer; e.Fenster = liste;
            e.PegelDb = Db(Math.Sqrt(sumQ / Math.Max(1, n))); e.SpitzeDb = Db(spitze);
            e.UebersteuertProzent = 100.0 * ueber / Math.Max(1, n); e.StilleProzent = 100.0 * still / Math.Max(1, n);
            return e;
        }
    }
}
'@
}

function Get-TonAnalyse([string]$Pfad, [double]$Ab = 0, [double]$BisZeit = -1, [double]$Schritt = 1) {
    [AgentHub.TonAnalyse]::Analysiere($Pfad, $Ab, $BisZeit, $Schritt)
}

## Pearson-Korrelation zweier gleich langer Zahlenreihen (null, wenn sie sich nicht berechnen lässt).
function Get-Korrelation([double[]]$X, [double[]]$Y) {
    if ($X.Count -lt 3 -or $X.Count -ne $Y.Count) { return $null }
    $mx = ($X | Measure-Object -Average).Average; $my = ($Y | Measure-Object -Average).Average
    $sxy = 0.0; $sxx = 0.0; $syy = 0.0
    for ($i = 0; $i -lt $X.Count; $i++) { $dx = $X[$i] - $mx; $dy = $Y[$i] - $my; $sxy += $dx * $dy; $sxx += $dx * $dx; $syy += $dy * $dy }
    if ($sxx -le 0 -or $syy -le 0) { return $null }
    return $sxy / [math]::Sqrt($sxx * $syy)
}

## Bericht als Textzeilen. Werte: Hashtable Name -> Liste von @{ Zeit; Wert } (z. B. Tempo aus dem Spieltest).
function Format-TonBericht($Ergebnis, [hashtable]$Werte = @{}) {
    $de = [Globalization.CultureInfo]'de-DE'
    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add(('Ton: {0} Hz, {1} Kanäle, {2} Bit, Aufnahme {3} s' -f $Ergebnis.Rate, $Ergebnis.Kanaele, $Ergebnis.Bits, $Ergebnis.Dauer.ToString('0.0', $de)))
    [void]$lines.Add(('Gesamt: Pegel {0} dBFS (RMS), Spitze {1} dBFS, übersteuert {2} %, still {3} %' -f `
        $Ergebnis.PegelDb.ToString('0', $de), $Ergebnis.SpitzeDb.ToString('0', $de), $Ergebnis.UebersteuertProzent.ToString('0.0', $de), $Ergebnis.StilleProzent.ToString('0', $de)))
    $hinweise = @()
    if ($Ergebnis.StilleProzent -ge 95) { $hinweise += 'Fast nur Stille: Kommt überhaupt Ton?' }
    if ($Ergebnis.UebersteuertProzent -ge 0.1) { $hinweise += 'Übersteuert: Lautstärke senken.' }
    if ($Ergebnis.SpitzeDb -lt -30 -and $Ergebnis.StilleProzent -lt 95) { $hinweise += 'Sehr leise.' }
    foreach ($name in $Werte.Keys) {
        $ton = @(); $wert = @()
        foreach ($f in $Ergebnis.Fenster) {
            $passend = @($Werte[$name] | Where-Object { $_.Zeit -ge $f.Zeit -and $_.Zeit -lt $f.Zeit + 1.0 })
            if ($passend.Count -gt 0 -and $f.TonhoeheHz -gt 0) { $ton += $f.TonhoeheHz; $wert += [double]$passend[0].Wert }
        }
        $r = Get-Korrelation $ton $wert
        if ($null -ne $r) { $hinweise += ('Tonhöhe folgt „{0}“: Korrelation {1} (1 = genau, 0 = gar nicht)' -f $name, $r.ToString('0.00', $de)) }
    }
    foreach ($h in $hinweise) { [void]$lines.Add("Hinweis: $h") }
    [void]$lines.Add('')
    $kopf = 'Zeit     Pegel   Spitze  Tonhöhe'
    foreach ($name in $Werte.Keys) { $kopf += '  ' + $name }
    [void]$lines.Add($kopf)
    foreach ($f in $Ergebnis.Fenster) {
        $zeile = '{0,6} s {1,5} dB {2,5} dB {3,6}' -f $f.Zeit.ToString('0', $de), $f.PegelDb.ToString('0', $de), $f.SpitzeDb.ToString('0', $de), $(if ($f.TonhoeheHz -gt 0) { '{0} Hz' -f [int]$f.TonhoeheHz } else { '–' })
        foreach ($name in $Werte.Keys) {
            $passend = @($Werte[$name] | Where-Object { $_.Zeit -ge $f.Zeit -and $_.Zeit -lt $f.Zeit + 1.0 })
            $zeile += '  ' + $(if ($passend.Count -gt 0) { "$($passend[0].Wert)" } else { '' })
        }
        [void]$lines.Add($zeile)
    }
    return ,$lines
}

if ($NurLaden) { return }
if (-not $Wav -or -not (Test-Path -LiteralPath $Wav)) { Write-Host 'Aufruf: ton.ps1 -Wav <datei> [-Von 0] [-Bis 30] [-Fenster 1]'; exit 1 }
$ergebnis = Get-TonAnalyse (Resolve-Path -LiteralPath $Wav).Path $Von $Bis $Fenster
foreach ($line in (Format-TonBericht $ergebnis)) { Write-Host $line }
