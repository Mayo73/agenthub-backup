# Agent Hub

Eine Pipeline, die deine Projekte rund um die Uhr automatisch umsetzt: Spiele, Tools, Web-Apps, Skripte.

| Wer | Macht was |
|---|---|
| **Du + ChatGPT** | Ideen besprechen, Lastenheft schreiben (Zielsetzung, Abnahmekriterien, Rahmenbedingungen), freigeben |
| **Claude** | Warteschlange führen, Projekte aufsetzen, Meilensteine und Tickets planen, Ergebnisse prüfen und übernehmen |
| **Lokale Agents** | Tickets programmieren (qwen3.5 über Ollama, auf deinem PC) |

## So kommt ein Projekt in den Hub

1. **ChatGPT einrichten (einmalig):** In der ChatGPT-Desktop-App einen lokalen Chat bzw. ein lokales Projekt („Auf meinem Computer“) mit dem Ordner `C:\Users\wiens\AgentHub\lastenhefte` anlegen. Dort liegt `AGENTS.md`, die ChatGPT automatisch liest: seine Rolle, die Lastenheft-Vorlage und die Regeln. Freigeben musst du nur diesen einen Ordner. Falls ein lokaler Chat innerhalb eines ChatGPT-„Projekts“ Probleme macht, einen eigenständigen lokalen Chat nehmen.
2. **Idee besprechen:** ChatGPT fragt nach, schlägt vor und schreibt das Lastenheft `lastenhefte/<projekt>.md` mit Status „Entwurf“. Es fragt auch, ob du einen grafischen Ablaufplan willst.
3. **Freigeben:** Sag „passt, freigeben“. ChatGPT setzt den Status auf „bereit“.
4. **Claude übernimmt** beim nächsten Review (0, 4, 8, 12 oder 21 Uhr): prüft das Lastenheft (bei Unklarheiten kommen Rückfragen), stellt es in die Warteschlange und startet es, sobald es dran ist.
5. **Stand und Fragen:** ChatGPT liest `lastenhefte/STATUS.md`, die etwa jede Minute neu geschrieben wird. Frag einfach „Wie ist der Stand?“ oder „Was ist offen?“. Deine Antworten trägt ChatGPT als Rückmeldung ins Lastenheft ein, Claude übernimmt sie beim nächsten Review.

**Warteschlange:** Es ist immer ein Projekt in Arbeit. Ist es fertig, oder kommt es nur mit deiner Antwort weiter, startet automatisch das nächste (nach Priorität, dann Datum). Begonnene Projekte haben Vorrang. Fehlende Software (z. B. Python) installiert Claude selbst über winget, solange das ohne Admin-Bestätigung geht; sonst fragt er.

## Bedienung

| Was | Wie |
|---|---|
| Starten | Doppelklick auf `start-hub.cmd` (startet auch automatisch beim Anmelden; der Wächter startet ihn alle 15 Minuten neu, falls er abgestürzt ist oder hängt) |
| Dashboard | `Dashboard.url` oder http://localhost:8787 |
| Dashboard auf dem Handy | Tailscale-App verbinden, dann https://desktop-niko.tail810eaa.ts.net:8443 (nur in deinem Tailnet erreichbar; abschalten mit `tailscale serve --https=8443 off`) |
| Projekte und Warteschlange | Reiter „Projekte“ (http://localhost:8787/#projekte) |
| Ablaufplan mit Prognose | Reiter „Ablaufplan“ (http://localhost:8787/#plan) |
| Pausieren | Knopf „Pausieren“ im Dashboard (das laufende Ticket wird noch fertig) |
| Beenden | `stop-hub.cmd` (bleibt aus, bis du `start-hub.cmd` startest; auch Wächter und Reviews starten ihn dann nicht) |
| Kennzahlen | `powershell -File hub\stats.ps1`: Dauer, Erfolgsquote und Nachbesserungen je Modell, Auslastung |
| Drift spielen | Desktop-Verknüpfung „Drift spielen“ |

## Die Spalten im Board

- **Offen:** wartet auf den Worker. „wartet auf T-…“: Das Ticket startet, sobald sein Vorgänger die Prüfung bestanden hat.
- **In Arbeit:** der Agent arbeitet oder die Prüfung läuft.
- **Zur Prüfung:** Prüfung bestanden, das Ergebnis liegt im Branch `agent/T-…` und wartet auf Claudes Review.
- **Fehlgeschlagen:** auch nach allen Versuchen nicht bestanden. Claude teilt es auf oder erledigt es selbst. Mit „Erneut versuchen“ stellst du es wieder in die Warteschlange.
- **Erledigt:** gemergt oder bewusst abgelehnt (der Grund steht am Ende des Tickets).

## Wenn etwas nicht läuft

- **„Worker aus“:** `start-hub.cmd` starten. Normalerweise erledigt das nach spätestens 15 Minuten der Wächter (Windows-Aufgabe `AgentHub-Waechter` in der Aufgabenplanung).
- **„Wartet auf Ollama“:** die Ollama-App starten (Startmenü → Ollama).
- **Nichts passiert über Nacht:** Der PC darf nicht in den Energiesparmodus gehen (Einstellungen → System → Energie → Energiesparmodus „Nie“), und die Claude-App muss für die Reviews geöffnet sein.
- **Details zu einem Ticket:** im Dashboard anklicken, oder `runs\T-…\report.md` lesen.

## Dateien

- `lastenhefte/`: Lastenhefte von ChatGPT, dazu `AGENTS.md`, `VORLAGE.md`, `STATUS.md`
- `auftraege.md`: Aufträge je Projekt, aus denen Tickets werden
- `plans/`: Ablaufpläne je Projekt
- `tickets/`: alle Tickets, nach Status sortiert
- `runs/`: Protokolle pro Ticket (Prompts, Agent-Antworten, Prüfausgaben, Diffs)
- `reviews/`: Claudes Review-Protokolle
- `projects/`: deine Projekte (Git-Repositorys)
- `config.json`: Modell, Zeitlimits, Review-Zeiten, Projekte
- `CLAUDE.md`: Arbeitsanweisung für Claude
