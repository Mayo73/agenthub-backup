---
id: T-0207
title: Dokumentation der acht Zelltypen (Darstellung und Verhalten)
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 5 verlangt, dass für alle acht Zelltypen Darstellung und Verhalten dokumentiert sind und die Vorführszenen benannt werden. Die Angaben stehen alle im Code; diese Datei fasst sie für den Nutzer auf Deutsch zusammen.

## Dateien
- `docs/zelltypen.md`: neu
- `tests/test_doku_zelltypen.gd`: neu

## Akzeptanzkriterien
- Lies dafür `scripts/species_catalog.gd` (Tabelle `SPECIES`: Name, Größenabschnitt, Ernährung, Verhalten, Tempo, Gesundheit, Bissschaden, Farbe, Muster, Streckung), `scripts/ai_brain.gd` (wie Jagen, Fliehen, Nahrungssuche und Treiben entschieden werden), `scripts/ai_cell.gd` (Zeichnung, z. B. Stacheln der Stachelkugel) und `scripts/demo_scenes.gd` (Vorführszenen).
- `docs/zelltypen.md` beginnt mit der Überschrift `# Zelltypen der Zellenphase`.
- Darunter eine Tabelle mit genau einer Zeile je Art und den Spalten `Art | Abschnitt | Ernährung | Verhalten | Aussehen | Gefahr für den Spieler`. In der Spalte „Art“ steht der Name aus `SPECIES` (z. B. `Blasenling`, `Hornjäger`); „Gefahr“ nennt den Bissschaden (0 = harmlos).
- Danach je Art ein Abschnitt `## <Name>` mit 2–4 Sätzen: wie die Art aussieht, wie sie sich verhält (wen sie jagt, vor wem sie flieht, was sie frisst) und ab welchem Größenabschnitt der Spieler sie fressen kann.
- Zum Schluss ein Abschnitt `## Vorführung` mit den Startbefehlen der Szenen „jagd“, „flucht“ und „nahrung“, jeweils als `-- --szene=jagd` usw., und einem Satz, was zu sehen ist (Text aus `DemoScenes.SCENES`).
- Keine Datei unter `scripts/` ändern.

## Tests
`tests/test_doku_zelltypen.gd` mit `extends "res://tests/base_test.gd"` und `const PATH := "res://docs/zelltypen.md"`:
- `test_datei`: `FileAccess.file_exists(PATH)` wahr; `FileAccess.get_file_as_string(PATH).begins_with("# Zelltypen der Zellenphase")` wahr
- `test_alle_arten`: `var text := FileAccess.get_file_as_string(PATH)`; für jede `id` aus `SpeciesCatalog.ids()`: `text.contains("## " + SpeciesCatalog.name_of(id))` wahr
- `test_vorfuehrung`: `var text := FileAccess.get_file_as_string(PATH)` → `text.contains("## Vorführung")` wahr; `text.contains("--szene=jagd")` wahr; `text.contains("--szene=flucht")` wahr; `text.contains("--szene=nahrung")` wahr

Review (17.10.2026): gemergt, nachgebessert: Beschreibungen erfanden Fähigkeiten der KI-Arten (Giftwolken, Entladen, Herden), Fress-Abschnitte an AiBrain angepasst.
