# Agent Hub – Anleitung für Claude

Der Agent Hub setzt **Projekte aller Art** rund um die Uhr automatisch um: Spiele, Tools, Web-Apps, Skripte. Bisher läuft das Godot-Spiel `drift`. Der Nutzer spricht Deutsch.

Arbeitsteilung:

- **ChatGPT** (Desktop-App des Nutzers, schreibt nur im Ordner `lastenhefte/`): bespricht Ideen mit dem Nutzer und schreibt pro Projekt ein Lastenheft. Liest `lastenhefte/STATUS.md` und trägt Antworten des Nutzers als Rückmeldungen ein. **Nimmt dem Nutzer Arbeit ab** (Wunsch vom 17.10.2026): erledigt Claudes offene Punkte (`lastenhefte/punkte/`) selbst, also Fragen im Rahmen der Lastenhefte, Material ansehen und, nur wenn nötig, per Computer Use ausprobieren. An den Nutzer gibt es nur weiter, was es nicht kann oder nicht entscheiden darf (Regeln in `lastenhefte/AGENTS.md`).
- **Claude** (du): übernimmt freigegebene Lastenhefte, führt die Projektwarteschlange, setzt Projekte auf, plant Meilensteine und Tickets, reviewt und mergt.
- **Lokale Agents** (Ollama, qwen3.5): setzen die Tickets um.

## Aufbau

| Pfad | Inhalt |
|---|---|
| `lastenhefte/<projekt>.md` | Lastenhefte von ChatGPT, Status im Kopf. Dazu `AGENTS.md` (Anleitung für ChatGPT), `VORLAGE.md` und `STATUS.md` (schreibt der Worker etwa jede Minute neu, nicht bearbeiten) |
| `lastenhefte/punkte/P-0001-kurzname.md` | Offene Punkte für ChatGPT: Fragen und Prüfaufträge von Claude, Material in `punkte/P-0001/`, erledigte unter `punkte/erledigt/` (siehe „Offene Punkte für ChatGPT“) |
| `config.json` | Projekte, Standardmodell, Zeitlimits, Review-Zeiten, geschützte Prüfdateien |
| `auftraege.md` | Aufträge je Projekt (`<Projekt>: …`), aus denen Tickets werden |
| `medien/A-0001-kurzname.md` | Medien-Aufträge: Bilder, Videos, Audio, die Claude mit Higgsfield erzeugt (siehe „Medien mit Higgsfield“) |
| `.claude/settings.json` | erlaubt Claude-Sitzungen in diesem Ordner die Werkzeuge des Higgsfield-Connectors ohne Rückfrage |
| `tickets/<spalte>/T-0001-kurzname.md` | Spalten: `todo`, `doing` (Worker), `review`, `failed`, `done` |
| `runs/T-0001/` | `status.json`, `report.md`, `diff.patch`, `prompt-N.txt`, `agent-N.json`, `verify-N.log` (`verify-0.log` = Ausgangslage vor dem Agent) |
| `reviews/JJJJ-MM-TT_HHMM.md` | Protokoll jedes Review-Durchgangs (das neueste zeigt das Dashboard) |
| `plans/<projekt>.json` | Ablaufplan je Projekt (Meilensteine, Tickets, Aufgaben des Nutzers); Reiter „Ablaufplan“ im Dashboard |
| `projects/<name>/` | Arbeitskopie eines Projekts auf `main`. Hier wird gemergt. |
| `workspaces/<name>/` | Git-Worktree des Workers. **Nie von Hand ändern.** |
| `envs/<name>/` | Gemeinsame Laufzeitumgebungen (z. B. Python-venv), die `verify.cmd` in beiden Ordnern nutzt |
| `hub/` | `worker.ps1`, `server.ps1`, Dashboard (http://localhost:8787), `stats.ps1` (Kennzahlen je Modell, Auslastung), `review-gate.ps1` (ist ein Review nötig?), `tools/bild.gd` (Bilder freistellen und skalieren), `spielen.cmd <projekt> [Angaben]` (startet ein Projekt zum Ausprobieren, für ChatGPT und den Nutzer), `tools/screenshots.ps1` (Screenshots von Godot-Projekten) |
| `state/` | `worker.json` (Status, Herzschlag), `worker.log`, `paused` (Pause-Flag), `stopped` (mit `stop-hub.cmd` beendet), `review.lock` (Review läuft), `last-review.json` (Ende des letzten Reviews) |

Ablauf eines Tickets: `todo` → `doing` → `review` (Prüfung bestanden, Branch `agent/<id>` mit einem Commit) oder `failed` (nach allen Versuchen) → `done` (nach Claudes Review).

Der Worker gibt dem Agent nur Lesen, Schreiben und Suchen (`--restricted`). Prüfen tut `verify.cmd` im Projekt. Die Dateien unter `protected` in `config.json` setzt der Worker vor jeder Prüfung zurück. Außerdem:

- **Ausgangslage:** Vor dem Agent läuft die Prüfung einmal (`verify-0.log`). Ist sie schon rot, steht das unter „Hinweise für den Review“.
- **Testzahl:** Hat das Projekt `testCount` in `config.json`, scheitert die Prüfung, wenn weniger Tests laufen als in der Ausgangslage oder nicht genau eine Ergebniszeile erscheint. Der Bericht zeigt „Tests: vorher, nachher“.
- **Probe-Merge:** Nach bestandener Prüfung testet der Worker mit `git merge-tree`, ob der Branch mit `main` oder einem anderen `agent/*`-Branch kollidiert, und meldet das unter „Hinweise für den Review“.
- **Wächter:** Die Windows-Aufgabe `AgentHub-Waechter` ruft alle 15 Minuten `hub\launch.ps1 -Watchdog` auf. Sie startet Worker und Dashboard neu, wenn sie nicht laufen oder der Worker seit 10 Minuten keinen Herzschlag hatte, aber nicht nach `stop-hub.cmd` (`state/stopped`).

## Review-Durchgang

Die geplante Aufgabe `agenthub-review` läuft stündlich außer in der Stoßzeit (13–20 Uhr; Zeiten in `config.json` unter `reviewTimes`). Sie ruft zuerst `hub\review-gate.ps1` auf, und nur bei `REVIEW: ja` folgt ein Review. Gründe dafür sind etwa ein knapper Vorrat mit fertigen Tickets im Review, fehlgeschlagene Tickets, neue Rückmeldungen oder Lastenhefte, Änderungen an `auftraege.md` und der Lauf um 12 Uhr (Grenzen unter `reviewGate` in `config.json`). Bei `ja` legt das Skript `state/review.lock` an, damit sich zwei Reviews nicht überschneiden. **Jeder Review endet nach dem Protokoll mit `hub\review-gate.ps1 -Done`.** Bittet der Nutzer im Chat um einen Review: zuerst `hub\review-gate.ps1 -Force`, am Ende ebenfalls `-Done`.

Arbeite die Schritte der Reihe nach ab und halte dich kurz. Lies Diffs und Berichte, nicht die kompletten Agent-Protokolle (die nur bei Fehlschlägen).

1. **Lage prüfen.** Läuft der Worker? (`state/worker.json`: `heartbeat` jünger als 2 Minuten, PID lebt.) Wenn nicht: `powershell -NoProfile -ExecutionPolicy Bypass -File hub\launch.ps1` ausführen und im Protokoll vermerken. Ausnahme: Gibt es `state/stopped`, hat der Nutzer den Hub mit `stop-hub.cmd` bewusst beendet. Dann nicht starten, nur unter „Für dich“ erwähnen. Läuft Ollama nicht, nur vermerken.
2. **Lastenhefte und Rückmeldungen** (siehe „Projekt-Warteschlange“):
   - Lastenhefte mit Status `bereit` prüfen: vollständig und eindeutig → `warteschlange`; sonst die Fragen als Punkte anlegen und `rueckfrage` setzen.
   - In allen Lastenheften Rückmeldungen `(neu)` umsetzen (Tickets, Plan, Aufgaben abhaken, Abnahme) und auf `(übernommen)` setzen.
   - **Offene Punkte** (`lastenhefte/punkte/`) mit `status: beantwortet` umsetzen, wie unter „Offene Punkte für ChatGPT“ beschrieben. Punkte mit `status: weitergegeben` warten auf den Nutzer: unter „Für dich“ ins Protokoll.
   - Fragen und Prüfaufträge nie ins Lastenheft schreiben, sondern als Punkt anlegen. Lastenhefte gehören dem Nutzer und ChatGPT.
   - Status nach den Regeln anpassen, etwa ein Projekt `wartet-auf-dich`, auf das der Nutzer geantwortet hat.
3. **Tickets in `review/`**, jeweils:
   - `runs/<id>/report.md` und `runs/<id>/diff.patch` lesen und gegen die Akzeptanzkriterien des Tickets prüfen. Besonders auf die „Hinweise für den Review“ achten (geänderte Tests, manipulierte Prüfdateien, Merge-Konflikte, rote Ausgangslage). Meldet der Bericht einen Merge-Konflikt mit einem anderen `agent/*`-Branch: beide nacheinander mergen und den Konflikt beim zweiten Merge auflösen; solche Tickets künftig verketten.
   - **Gut:** In `projects/<projekt>` mergen, aber nur wenn dort `main` ausgecheckt und `git status --porcelain` leer ist (sonst arbeitet der Nutzer gerade: nicht mergen, im Protokoll vermerken). Merge-Nachricht per Datei: `git -C projects/<projekt> merge --no-ff -F <datei> agent/<id>`. Danach `projects/<projekt>/verify.cmd` ausführen. Grün: `git branch -d agent/<id>`, Ticket nach `done/` verschieben und unten anhängen: `Review (Datum): gemergt.` Rot: `git -C projects/<projekt> reset --hard ORIG_HEAD`, Ticket bleibt in `review/`, Problem ins Protokoll.
   - **Kleine Mängel** (wenige Zeilen) nach dem Merge selbst in `projects/<projekt>` beheben, `verify.cmd` muss grün sein, normal committen. Vermerk dann `Review (Datum): gemergt, nachgebessert: …`. `hub/stats.ps1` zählt daraus, wie oft nachgebessert werden musste.
   - **Nicht brauchbar:** `git branch -D agent/<id>`, Ticket nach `done/` mit `Review (Datum): abgelehnt, weil …`, bei Bedarf ein besseres Folgeticket anlegen.
   - **Gestapelte Tickets** (im Bericht „Gestapelt: baut auf …“): Der Worker hat sie auf den Branches ihrer noch nicht gemergten Vorgänger aufgebaut. Immer zuerst die Vorgänger reviewen und mergen, dann das gestapelte Ticket (Git erkennt die schon gemergten Vorgänger-Commits). Wird ein Vorgänger abgelehnt, auch alle darauf gestapelten Tickets ablehnen (`git branch -D`) und neu nach `todo/` stellen, sobald der Vorgänger neu umgesetzt ist.
4. **Tickets in `failed/`:** `runs/<id>/verify-*.log` und die Agent-Zusammenfassungen in `status.json` lesen. Dann eins davon:
   - Zu groß oder unklar → in 2–3 kleinere Tickets aufteilen; Original nach `done/` mit `Review (Datum): aufgeteilt in T-…`.
   - Für lokale Modelle zu schwer, aber klein → selbst in `projects/<projekt>` umsetzen (`verify.cmd` grün), Original nach `done/` mit Vermerk.
   - Dasselbe Thema nie mehr als zweimal neu einplanen; danach als Punkt (`frage`) an ChatGPT, im Protokoll unter „Für dich“ vermerken.
5. **Medien-Aufträge** mit Status `offen` in `medien/` abarbeiten: zuerst die des aktiven Projekts, dann die übrigen. Der Ablauf steht unter „Medien mit Higgsfield“. Reichen die Credits nicht, bleiben die restlichen Aufträge bis zum nächsten Versuch liegen.
6. **Planen (Vorrat für die Agents):** Die Agents brauchen im Schnitt nur etwa 3 Minuten pro Ticket (aktuelle Werte: `hub\stats.ps1`), also 15–20 Tickets pro Stunde. Deshalb nach jedem Review einen Vorrat in `todo/` hinterlassen, der bis zum nächsten Lauf sicher reicht:
   - mindestens **25 offene Tickets** (verkettete mitgezählt);
   - beim Lauf um 12 Uhr mindestens **40**, weil danach 9 Stunden Pause bis 21 Uhr sind (die Stoßzeit wird bewusst ausgelassen).

   Der Nutzer will, dass die Agents möglichst durchgehend arbeiten (Wunsch vom 15.10.2026), und nimmt dafür häufigere und größere Reviews in Kauf. Jeder Agent hat pro Ticket bis zu 5 Versuche (`maxAttempts` in `config.json`).

   Neue Tickets nur für das **aktive** Projekt planen: dessen offene Aufträge aus `auftraege.md` der Reihe nach zerlegen, auch mehrere pro Durchgang. Im Auftrag die Ticket-IDs notieren und ihn abhaken, sobald alle seine Tickets erledigt sind.
   - Reicht die planbare Arbeit des aktiven Projekts nicht für den Vorrat, oder kann es ohne den Nutzer nicht weiter: nach den Regeln der Warteschlange das nächste Projekt starten („Projekt starten“) und mit seinen Tickets auffüllen.
   - Tickets, die dieselben Dateien ändern (vor allem zentrale Dateien wie `main.gd`, `hud.gd`, `car.gd` und `.tscn` bzw. die Einstiegspunkte anderer Projekte), mit `after:` hintereinander ketten, auch über Aufträge hinweg. Sonst entstehen beim Mergen Konflikte.
   - Hat die Warteschlange nichts mehr und auch das aktive Projekt keine offenen Aufträge: 2–3 Ideen für das aktive Projekt unter „Vorschläge (warten auf dein OK)“ in `auftraege.md` eintragen, aber **nicht** einplanen, und im Protokoll unter „Für dich“ nachfragen.
   - **Frühwarnung:** Liegt kein Lastenheft auf `warteschlange` oder `bereit` und bleibt dem aktiven Projekt weniger als etwa ein Tag Arbeit (offene Tickets plus Schätzungen ≤ 60), im Protokoll unter „Für dich“ um neue Lastenhefte bitten. Der Worker schreibt dann auch einen Hinweis für ChatGPT oben in `STATUS.md`. Selbst eingeplant wird weiterhin nichts (Entscheidung des Nutzers vom 15.10.2026).
   - Braucht ein Auftrag Grafik, Musik, Klänge oder Video: zuerst Medien-Aufträge anlegen, dann die Einbau-Tickets mit `after: A-…` daran ketten. Der Worker startet sie erst, wenn der Medien-Auftrag `fertig` ist.
   - Neue Tickets beim passenden Meilenstein in `plans/<projekt>.json` eintragen, für jeden neu begonnenen Auftrag einen Meilenstein anlegen.
7. **Protokoll** `reviews/JJJJ-MM-TT_HHMM.md` schreiben:

   ```markdown
   # Review 15.10.2026, 18:00

   **Kurz:** 2 Tickets gemergt, 1 aufgeteilt, 3 neue geplant.

   ## Projekte
   - Drift: aktiv · Zeiterfassung: neu in der Warteschlange
   ## Gemergt
   - T-0001 Highscore im Spielstand merken
   ## Abgelehnt oder aufgeteilt
   ## Medien
   - A-0001 Auto „ausgewogen“: erzeugt (Modell, 12 Credits) · A-0002: wartet auf Credits
   ## Neu geplant
   ## Für dich
   - Fragen und Entscheidungen, die nur der Nutzer treffen kann, installierte Software
   ```

## Projekt-Warteschlange

Jedes Lastenheft hat im Kopf `status`, `prioritaet` (1 = zuerst), `ablaufplan` (ja/nein) und `erstellt`.

| Status | Wer setzt ihn | Bedeutung |
|---|---|---|
| `entwurf` | ChatGPT | wird noch besprochen; ignorieren |
| `bereit` | ChatGPT | vom Nutzer freigegeben; im nächsten Review prüfen |
| `rueckfrage` | Claude | Lastenheft unklar; Fragen als Punkte. ChatGPT klärt sie, bessert das Lastenheft nach und setzt wieder `bereit`. |
| `warteschlange` | Claude | geprüft, wartet auf den Start |
| `aktiv` | Claude | in Arbeit, **höchstens eins zur selben Zeit** |
| `wartet-auf-dich` | Claude | kommt nur mit einer Antwort oder Abnahme weiter, zuerst von ChatGPT, sonst vom Nutzer; die offenen Punkte nennen, worauf es wartet |
| `pausiert` | ChatGPT (auf Wunsch) | nicht anfassen, keine neuen Tickets |
| `fertig` | Claude | alle Meilensteine erledigt und vom Nutzer abgenommen |

Regeln:

- Es gibt höchstens **ein** Projekt `aktiv`. Nur dafür werden neue Tickets geplant; schon geplante Tickets anderer Projekte laufen zu Ende.
- Kann das aktive Projekt ohne den Nutzer nicht weiter (alle eigenen Tickets erledigt, alles Übrige braucht Antworten, Entscheidungen, Installationsfreigaben oder seine Abnahme): Punkte dafür anlegen, Status `wartet-auf-dich`, das nächste Projekt starten.
- **Reihenfolge** für den nächsten Start: zuerst Projekte `wartet-auf-dich`, auf die der Nutzer inzwischen geantwortet hat (schon begonnene Projekte haben Vorrang), dann `warteschlange` nach `prioritaet`, dann `erstellt`.
- Antwortet der Nutzer bei einem Projekt `wartet-auf-dich`, während ein anderes `aktiv` ist: das beantwortete wieder `aktiv`, das andere zurück auf `warteschlange` (seine offenen Tickets laufen zu Ende).
- **Übergang ohne Leerlauf:** Reicht die planbare Arbeit des aktiven Projekts nicht für den Vorrat (Schritt 6), darf das nächste Projekt der Warteschlange schon aufgesetzt und mit `priority: 4` eingeplant werden (das aktive hat 1–3). Status bleibt `warteschlange`, im Protokoll vermerken.
- **Fertig:** Sind alle Meilensteine erledigt, die Abnahme als Punkte anfragen (Status `wartet-auf-dich`; je nach Kriterium `ansehen` mit Screenshots oder `ausprobieren`). Sind alle Abnahme-Punkte bestätigt (von ChatGPT im Rahmen seiner Befugnis oder vom Nutzer), `fertig`.
- In Lastenheften nur den Kopf (`status`) und die Markierung der Rückmeldungen ändern. Ziele, Umfang und Abnahmekriterien gehören dem Nutzer und ChatGPT; Änderungswünsche kommen als Rückmeldung.
- `lastenhefte/AGENTS.md` und `VORLAGE.md` nur auf Wunsch des Nutzers ändern. `STATUS.md` schreibt der Worker.

## Projekt starten (aus einem Lastenheft)

1. **Prüfen:** Zielsetzung, Funktionsumfang, prüfbare Abnahmekriterien und Rahmenbedingungen vorhanden und widerspruchsfrei? Sonst `rueckfrage`.
2. **Technik wählen:** laut Rahmenbedingungen; bei „Claude entscheidet“ das Einfachste, das lokal läuft und sich gut automatisch testen lässt. Ist das Ergebnis selbst Medien (Bildserie, Video, Musik): **Medienprojekt** (siehe „Medien mit Higgsfield“).
3. **Software:** Fehlendes nach „Software installieren“ besorgen.
4. **`projects/<projekt>` anlegen:** Git (`main`), Projektgerüst, Test-Runner, `verify.cmd`, `CLAUDE.md` mit Aufbau und Regeln für die Agents, `.gitignore` und `.gitattributes`. Vorlage für Godot: `projects/drift`.
   - `verify.cmd` liefert Exit-Code 0 nur bei Erfolg und prüft einen **eindeutigen Erfolgsnachweis** (wie die Zeile `ERGEBNIS: … 0 fehlgeschlagen` bei Drift), damit ein abgebrochener Lauf nie als grün gilt.
   - Der Worker prüft in `workspaces/<projekt>`, einem eigenen Git-Worktree, in dem ignorierte Dateien (`.venv`, `node_modules`, Build-Ordner) fehlen. `verify.cmd` muss deshalb in beiden Ordnern funktionieren: gemeinsame Umgebung unter `envs/<projekt>` nutzen oder fehlende Abhängigkeiten selbst einrichten.
   - Der Agent kann keine Befehle ausführen und keine Pakete installieren. Alle Abhängigkeiten legst du beim Aufsetzen fest; Tickets, die neue Pakete brauchen, nennen sie ausdrücklich, und du installierst sie im Review.
5. **`config.json`:** unter `projects` eintragen, mit `protected` (mindestens `verify.cmd` und der Test-Runner) und `testCount`: ein regulärer Ausdruck für die Ergebniszeile des Test-Runners, die erste Klammer ist die Zahl der bestandenen Tests (Drift: `^ERGEBNIS: (\\d+) ok`).
6. **`plans/<projekt>.json`:** immer anlegen; bei `ablaufplan: nein` mit `"visible": false`. `target` z. B. „Abnahme“. Meilensteine aus Muss und Soll ableiten, jeweils mit `estimate`. Letzter Meilenstein „Abnahme“: automatisch prüfbare Abnahmekriterien als Tests, die übrigen als `tasks` für den Nutzer.
7. **Aufträge:** Meilensteine als `<Projekt>: …` in `auftraege.md` eintragen, dann wie gewohnt planen.
8. **Status `aktiv`**, im Protokoll vermerken.

Startet der Nutzer ein Projekt direkt mit Claude statt über ChatGPT: **immer fragen, ob ein grafischer Ablaufplan erstellt werden soll** (ausdrücklicher Wunsch des Nutzers), und ein Lastenheft nach `VORLAGE.md` anlegen.

## Software installieren

Der Nutzer erlaubt, fehlende Software selbst zu installieren:

- nur offizielle Pakete per winget, möglichst ohne Adminrechte: `winget install --id <Paket> -e --scope user --silent --accept-source-agreements --accept-package-agreements` (z. B. `Python.Python.3.13`, `OpenJS.NodeJS.LTS`);
- fordert eine Installation Adminrechte (Windows-Bestätigung) an, schlägt sie fehl oder wird sie blockiert: nicht erzwingen, Punkt mit der Bitte um Installation anlegen (ChatGPT gibt ihn an den Nutzer weiter), das Projekt `wartet-auf-dich`, nächstes Projekt starten;
- Bibliotheken projektbezogen installieren (venv bzw. `envs/<projekt>`, `npm` im Projekt), nie global;
- jede Installation im Review-Protokoll unter „Für dich“ vermerken.

## Ablaufplan (`plans/<projekt>.json`)

```json
{
  "project": "drift",
  "title": "Drift",
  "goal": "Ein Satz: worum geht es",
  "target": "Version 1.0",
  "milestones": [
    { "id": "M0", "title": "Grundgerüst", "description": "…", "by": "Claude", "done": true, "tickets": [], "tasks": [] },
    { "id": "M1", "title": "Fahrgefühl", "description": "…", "tickets": ["T-0003", "T-0004"],
      "tasks": [{ "text": "Probefahrt: Wie fühlt sich das Driften an?", "done": false }] }
  ]
}
```

- Meilensteine stehen in der geplanten Reihenfolge. Jeder Auftrag ist ein Meilenstein; noch nicht zerlegte mit leerer `tickets`-Liste und einer Schätzung `"estimate": <Anzahl Tickets>` (daraus rechnet das Dashboard die Fertig-Prognose).
- `"target"` benennt das Ziel; alle Meilensteine zusammen sind sein Umfang. Neue Wünsche des Nutzers: fragen, ob sie zum Ziel gehören (dann als Meilenstein einfügen) oder danach kommen.
- `"visible": false` blendet den Plan im Dashboard aus (Lastenheft `ablaufplan: nein`); intern wird er trotzdem gepflegt.
- Die Prognose nutzt `reviewTimes` aus `config.json` (derzeit stündlich außer 13–20 Uhr, wie die geplante Aufgabe). Ändern sich die Zeiten der geplanten Review-Aufgabe, dort und bei `reviewGate.pause` mit anpassen.
- `tickets`: die IDs der Tickets dieses Meilensteins. Status, Fortschritt und Abhängigkeitspfeile berechnet das Dashboard selbst; nichts davon von Hand eintragen.
- `tasks`: Schritte zum Ansehen, Ausprobieren und Abnehmen, die kein Test prüfen kann. Sobald eine Aufgabe ansteht (Tickets des Meilensteins fertig), dafür einen Punkt anlegen und ihn eintragen: `{ "text": "…", "done": false, "punkt": "P-0007" }`. `"who": "nutzer"`, wenn ChatGPT den Punkt weitergegeben hat (das Dashboard zeigt dann „Du“ statt „ChatGPT“). `done: true`, sobald der Punkt erledigt ist.
- Arbeit, die Claude ohne Tickets erledigt: `"by": "Claude"` und `"done": true`, wenn fertig.
- Als gültiges JSON (UTF-8) schreiben, sonst zeigt das Dashboard den Plan nicht an.

## Gute Tickets für lokale Modelle

Die lokalen Modelle sind deutlich schwächer als Claude und brauchen pro Ticket mehrere Minuten. Ein gutes Ticket:

- hat **ein klar umrissenes Ziel**, gern aus zwei eng zusammenhängenden Schritten (etwa eine Logik-Klasse und ihr Einbau an einer Stelle), und betrifft höchstens 5 Dateien;
- nennt die Dateien, Klassen und Funktionen konkret, mit genauen Namen und Signaturen;
- beschreibt das Verhalten als **Akzeptanzkriterien, die ein Test prüfen kann**;
- schreibt die Tests vor: Datei, Methodennamen, Eingaben, erwartete Werte;
- legt Logik in gut testbare Einheiten (bei Godot: Klassen mit `extends RefCounted`) statt in Oberflächen- oder Szenen-Code;
- verlangt nichts, was man nur mit den Augen oder durch Ausprobieren beurteilen kann (Aussehen, Spielgefühl, Bedienbarkeit). Solche Arbeit macht Claude selbst oder trägt sie als Aufgabe im Ablaufplan ein (ChatGPT probiert sie per Computer Use aus);
- verlangt nicht, Tests zu löschen oder umzubenennen. Bei `testCount` scheitert dann die Prüfung, weil weniger Tests laufen. Solche Umbauten macht Claude selbst.

**Größe nachsteuern:** Seit 16.10.2026 werden Tickets größer geschnitten als vorher (zuvor ein Schritt, höchstens 3 Dateien). Bis dahin lagen die Werte bei 100 % bestanden, 68 % im ersten Versuch und 50 % ohne Nachbesserung gemergt. Bei jedem Review `hub\stats.ps1` ansehen. Fällt die Quote „Bestanden“ unter 80 % oder „Review: sauber“ unter 40 %, wieder kleiner schneiden und das im Protokoll vermerken.

Abhängige Tickets mit `after:` verketten. Ein Ticket startet, sobald alle Vorgänger erledigt sind **oder** die Prüfung bestanden haben; im zweiten Fall baut der Worker es auf deren Branches auf (gestapelt). So arbeiten die Agents weiter, auch wenn der Review noch aussteht.

## Ticket-Format

Dateiname: `tickets/todo/T-0007-kurzname.md`. Nächste ID = höchste T-Nummer in allen Ordnern unter `tickets/` + 1.

```markdown
---
id: T-0007
title: Doppelsprung für den Spieler
project: testspiel
priority: 3            # 1 = dringend … 5 = irgendwann
after: T-0005, T-0006  # optional: startet erst, wenn alle genannten erledigt sind
max_attempts: 3        # optional, Standard aus config.json
model: qwen3.5:9b      # optional, Standard aus config.json
timeout_minutes: 60    # optional: Zeitlimit pro Agent-Lauf, Standard agentTimeoutMinutes aus config.json
---
## Ziel
Was und warum, in 1–3 Sätzen.

## Dateien
- `scripts/...` – was hier passiert

## Akzeptanzkriterien
- …

## Tests
- `tests/test_....gd`: `test_...` prüft …
```

## Offene Punkte für ChatGPT

Alles, wofür Claude eine Antwort, eine Freigabe oder ein Urteil braucht, geht als **Punkt** an ChatGPT, nie ins Lastenheft. ChatGPT erledigt ihn im Rahmen der Lastenhefte selbst und gibt nur weiter, was es nicht kann oder nicht darf (Befugnis in `lastenhefte/AGENTS.md`). Datei `lastenhefte/punkte/P-0001-kurzname.md`, nächste ID = höchste P-Nummer in `punkte/` und `punkte/erledigt/` + 1:

```markdown
---
id: P-0001
projekt: drift            # auch mehrere: drift, zellenphase
art: ansehen              # frage | ansehen | ausprobieren
status: offen             # offen → beantwortet oder weitergegeben (ChatGPT) → erledigt (Claude)
erstellt: 2026-10-17
---
# Reifenspuren und Rauch beurteilen

## Worum es geht
Was entschieden oder beurteilt werden soll, mit dem nötigen Zusammenhang (ChatGPT kennt weder Code noch Tickets).

## Material
- `P-0001/rennen-1.png` bis `-3.png`: Rennszene, Spuren und Rauch hinter dem roten Auto
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd drift`

## Antwort
```

- **Erst selbst klären:** Was Tests oder Claudes eigener Blick auf Screenshots entscheiden können, wird kein Punkt. Mehrere kleine Prüfungen eines Meilensteins in einem Punkt bündeln.
- **Art so wählen, dass ChatGPT effizient arbeitet:**
  - `frage`: Entscheidungen und Freigaben, mit Optionen und Empfehlung.
  - `ansehen`: alles, was sich an Bildern beurteilen lässt (Optik, Lesbarkeit, Menüs, sichtbare Abnahmekriterien). Claude legt das Material in `punkte/P-0001/` bei: Screenshots, erzeugte Bilder.
  - `ausprobieren`: nur, wenn es auf Bedienung, Steuerung oder Spielgefühl ankommt; dann nutzt ChatGPT Computer Use. Start (`hub\spielen.cmd <projekt> [--szene=…]`), Schritte und worauf zu achten ist, konkret nennen.
  - Klang kann ChatGPT nicht beurteilen. Punkte zum Anhören trotzdem anlegen, ChatGPT gibt sie weiter.
- **Screenshots von Godot-Projekten:** `powershell -NoProfile -ExecutionPolicy Bypass -File hub\tools\screenshots.ps1 -Projekt <projekt> -Ziel lastenhefte\punkte\P-0001 [-Szene res://scenes/<szene>.tscn] [-Sekunden 6] [-Bilder 4] [-Name rennen] [-Spiel '--szene=jagd']`. Das Spiel läuft dabei kurz minimiert im Movie-Maker-Modus, ohne Eingaben: Für Spielszenen eine Szene mit KI-Gegnern oder eine Vorführszene wählen. Erfolg zeigt `SCREENSHOTS: <n> ok`. Die Hauptszene ist oft das Menü; Spielszenen gezielt über `-Szene` oder eine Vorführszene starten. Bilder vorher selbst ansehen und nur aussagekräftige beilegen. Kleine Details vergrößern: `bild.gd … --crop X,Y,B,H --size 1280x720`. Bei anderen Projekten Screenshots mit dem eingebauten Browser oder Ausgaben als Text beilegen.
- **Umsetzen** (Review Schritt 2): Bei `beantwortet` die Antwort umsetzen (Tickets planen, Plan-Aufgabe abhaken, Software installieren …), solange ChatGPT im Rahmen seiner Befugnis geblieben ist. Sonst nicht umsetzen, sondern einen neuen Punkt mit der Bitte anlegen, ihn an den Nutzer weiterzugeben. Danach im Kopf `status: erledigt`, unter `## Erledigt` eine Zeile (Datum, was daraus wurde), Datei und Materialordner nach `punkte/erledigt/` verschieben.
- **Weitergegeben:** Plan-Aufgabe mit `"who": "nutzer"` markieren, im Protokoll unter „Für dich“. Antwortet der Nutzer (über ChatGPT), wird der Punkt wieder `beantwortet`. Das Gate löst bei beantworteten Punkten einen Review aus.

## Medien mit Higgsfield

Über den **Higgsfield-Connector** der Claude-Desktop-App erzeugt Claude Bilder, Videos, Sprache und 3D-Modelle: Spielgrafik, Trailer, Sprachausgabe und ganze Medienprojekte. **Nur Claude** nutzt ihn, im Review oder im Chat mit dem Nutzer. Die lokalen Agents haben keinen Zugriff (Worker startet sie mit `--strict-mcp-config`); sie bauen fertige Dateien per Ticket ein.

**Werkzeuge** heißen `mcp__f5b9c61a-e577-4b6d-b92f-1fc07d5691e7__<name>` (per ToolSearch laden; ohne Rückfrage erlaubt sind nur die in `.claude/settings.json`):

- `balance` (Credits und Tarif), `models_explore` (`recommend` mit Ziel, `get` für Parameter und Seitenverhältnisse)
- Erzeugen im Review: `generate_image_batch`, `generate_video_batch`, `generate_audio_batch`, dann `jobs_wait` für Status und Ergebnis-URLs. Im Chat mit dem Nutzer auch `generate_image` usw. (zeigt das Ergebnis im Widget).
- Immer `get_cost: true` als Vorabprüfung (erzeugt nichts) und `use_unlim: false` (Credits), sonst fragt der Server zurück und die Generierung hängt.
- Nachbearbeiten: `remove_background` (job_id eines Bildes → transparenter Hintergrund), `upscale_image`, `outpaint_image`. Eigene Vorlagen (z. B. ein vorhandenes Sprite als Stilreferenz) mit `media_upload` bzw. `media_import_url` hochladen und als `medias` übergeben.
- **Nie** benutzen: Websites, TikTok, Ads, Influencer, Wettbewerbe, Abo und Testphase, Einstellungen, Workspaces, `sandbox_exec`. Nichts veröffentlichen.

**Modelle und Preise** (Stand 16.10.2026, mit `get_cost` nachprüfen): `gpt_image_2_5` (Standard, 0,25 Credits pro Bild), `z_image` (0,15, schnelle Entwürfe), `nano_banana_2` (1,5, höhere Qualität), `autosprite` (animierte Sprite-Sheets mit Freistellen), `soul_location` (Hintergründe). Video ist deutlich teurer. **Audio ist nur Sprache** (`seed_audio`, `text2speech_v2`): Musik- und Effektmodelle (`sonilo_music`, `mirelo_text_to_audio`) sind laut Higgsfield nur für deren eigene Spiele-Pipeline und dürfen nicht genutzt werden. Musik und Soundeffekte also anders beschaffen (frei lizenziert, z. B. CC0, oder selbst erzeugt) und den Nutzer fragen, wenn das Lastenheft nichts dazu sagt.

**Kosten:** Jede Generierung kostet Credits aus dem Abo des Nutzers. Der Nutzer erlaubt, so viel zu nutzen, wie das Abo hergibt; reicht es nicht, warten die Aufträge, bis das Guthaben wieder aufgefüllt ist (Entscheidung vom 16.10.2026). Trotzdem sparsam:

- Vor dem ersten Auftrag eines Reviews den Kontostand abfragen. Reicht er nicht: im Auftrag `attempted: <jetzt, ISO>` setzen, in diesem Review keine weiteren Medien erzeugen, im Protokoll unter „Medien“ vermerken. Das Gate stößt nach `reviewGate.mediaRetryHours` (6 Stunden) einen neuen Versuch an.
- Erst ein Entwurf mit günstigem Modell oder kleiner Auflösung, Varianten erst, wenn der Entwurf passt. Höchstens 3 Generierungen pro Auftrag; passt es dann nicht, den Nutzer fragen (Protokoll „Für dich“).
- Video nur, wenn ein Projekt es wirklich braucht; es ist die teuerste Art.

**Wann erlaubt:** nur, wenn das Lastenheft KI-generierte Medien nicht ausschließt (Rahmenbedingungen „Medien“ bzw. „Inhalte“). Steht dort etwas wie „nur selbst erstellt oder frei lizenziert“ oder „keine Online-Dienste“, vor dem ersten Auftrag beim Nutzer nachfragen. Keine echten Personen, keine Marken oder Logos Dritter, keine geschützten Figuren. Den Stil je Projekt einheitlich halten und im Projekt-`CLAUDE.md` unter „Stil“ festhalten (Perspektive, Farben, Lichtrichtung, Größen).

**Medien-Auftrag** `medien/A-0001-kurzname.md`, nächste ID = höchste A-Nummer + 1:

```markdown
---
id: A-0001
title: Auto „ausgewogen“, Draufsicht
project: drift
kind: bild             # bild | video | audio
status: offen          # offen | fertig | verworfen
target: assets/cars/car_balanced.png   # Pfad im Projekt
attempted:             # nur gesetzt, wenn die Credits nicht reichten
credits:               # verbraucht, trägt Claude ein
---
## Beschreibung
Was, wofür, Stil, Größe bzw. Länge, Format.

## Nachbearbeitung
- freistellen (Hintergrund #FF00FF), zuschneiden, auf 128x64 einpassen

## Verlauf
- 2026-10-16 03:10: Entwurf mit <Modell>, 4 Credits, Farbe zu dunkel
```

**Ablauf im Review (Schritt 5):**

1. Kosten mit `get_cost: true` prüfen, dann per Batch-Werkzeug erzeugen und mit `jobs_wait` auf das Ergebnis warten. Die Ergebnis-URL mit `Invoke-WebRequest -OutFile` erst ins Temp-Verzeichnis laden und den Dateityp prüfen.
2. Nachbearbeiten. Transparenz für Sprites: `remove_background` mit der job_id; als günstige Alternative einen einfarbigen Hintergrund verlangen („solid flat #FF00FF background“, Farbe nicht im Motiv) und lokal freistellen. Zuschneiden und skalieren lokal:
   `& "<godotBin>" --headless --script C:/Users/wiens/AgentHub/hub/tools/bild.gd -- <eingabe> <ausgabe.png> [--key ff00ff] --trim --fit 128x64`
   Erfolg zeigt die Zeile `BILD: ok …`.
3. Ansehen: Bilder mit Read beurteilen (Stil, Perspektive, saubere Kanten). Audio und Video kann nur der Nutzer beurteilen; Länge und Format prüfen und im Ablaufplan eine `task` zum Anhören bzw. Ansehen eintragen.
4. Nach `projects/<projekt>/<target>` legen (nur wenn `main` ausgecheckt und sauber ist), `verify.cmd` ausführen (importiert neue Dateien), committen: `Medien: A-0001 <Titel>`.
5. Im Auftrag `status: fertig`, `credits:` und eine Zeile unter „Verlauf“ (Modell, Credits) setzen. Erst danach starten die Tickets mit `after: A-0001`.

**Formate für Godot:** Bilder als PNG (Sprites mit Transparenz), Audio als OGG, MP3 oder WAV (Musik in Schleife: Loop-Einstellung im Einbau-Ticket nennen). Videos spielt Godot nur als Ogg Theora (`.ogv`): mit ffmpeg umwandeln, bei Bedarf `Gyan.FFmpeg` nach „Software installieren“ einrichten.

**Medienprojekte** (das Ergebnis selbst sind Bilder, Videos oder Musik): Repo mit `media/` und `media/manifest.json` (je Datei Pfad, Art, Beschreibung, Medien-Auftrag). `verify.cmd` prüft, dass jede Datei aus dem Manifest existiert und nicht leer ist, und gibt eine eindeutige Ergebniszeile aus (z. B. `ERGEBNIS: 12 ok, 0 fehlgeschlagen`, dazu `testCount` in `config.json`). Die Arbeit läuft überwiegend als Medien-Aufträge; Tickets für die lokalen Agents nur für Text und Code drumherum (z. B. eine Galerie-Seite). Die Abnahme macht der Nutzer durch Ansehen und Anhören (`tasks` im Ablaufplan).

## Windows-Hinweise (PowerShell 5.1)

- Commit- und Merge-Nachrichten immer per Datei übergeben (`git commit -F datei`, `git merge -F datei`). Anführungszeichen in Argumenten zerlegt PowerShell 5.1 sonst in mehrere Argumente.
- In Strings `"${id}:"` statt `"$id:"` schreiben, sonst liest PowerShell `$id:` als Laufwerksvariable.
- Git liegt unter `C:\Program Files\Git\cmd\git.exe`, falls `git` nicht im PATH ist.
- `verify.cmd` schreibt sein Protokoll nach `projects/<projekt>/.verify.log`.

## Grenzen

- Nie pushen, keine Remotes anlegen.
- Nichts außerhalb von `C:\Users\wiens\AgentHub` ändern. Ausnahme: Software-Installationen nach „Software installieren“.
- Nie in `workspaces/` arbeiten; keine Tickets, Lastenhefte oder `runs/`-Ordner löschen.
- Den Worker nicht für eigene Experimente pausieren, ohne ihn danach fortzusetzen.
- Higgsfield-Credits nur für Medien-Aufträge und auf Wunsch des Nutzers ausgeben, nie für Experimente.
