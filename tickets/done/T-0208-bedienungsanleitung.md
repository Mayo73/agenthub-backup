---
id: T-0208
title: Kurze Bedienungsanleitung für das Windows-Paket
project: zellenphase
priority: 3
after: T-0207
---
## Ziel
Zum Windows-Paket gehört laut Lastenheft eine kurze Bedienungsanleitung auf Deutsch. Sie entsteht jetzt schon als `docs/ANLEITUNG.md`; Claude legt sie später dem Paket bei.

## Dateien
- `docs/ANLEITUNG.md`: neu
- `tests/test_doku_anleitung.gd`: neu

## Akzeptanzkriterien
- Lies dafür `scripts/controls.gd` (Tasten), `scripts/cell_editor_canvas.gd` und `scripts/cell_editor.gd` (Editor-Tasten in `_unhandled_input`: Q und E drehen, Entf bzw. Rücktaste entfernen, Z rückgängig, Y wiederholen), `scripts/main.gd`, `scripts/diet.gd`, `scripts/part_catalog.gd`, `scripts/save_slots.gd` und `scripts/benchmark.gd`.
- `docs/ANLEITUNG.md` beginnt mit `# Zellenphase – Bedienungsanleitung` und hat genau diese Abschnitte in dieser Reihenfolge:
  - `## Spielstart`: EXE starten, Pflanzen- oder Fleischfresser wählen, einen der drei Spielstandplätze wählen
  - `## Steuerung`: linke Maustaste gedrückt halten (schwimmt zum Zeiger), alternativ WASD oder Pfeiltasten, Taste C oder rechte Maustaste für den Partnerruf, Esc für die Pause
  - `## Ziel`: Nahrung fressen, DNA sammeln, in fünf Größenabschnitten wachsen, Teile finden, zum Schluss „An Land gehen“
  - `## Nahrung und Mundwerkzeuge`: Filtermaul (Pflanzen), Kiefer (Fleisch), Rüssel (beides)
  - `## Zelleditor`: Partner rufen und erreichen, Teile wählen und platzieren, verschieben, drehen (Q/E), entfernen (Entf), Symmetrie, Farbe, Muster, Körperform, rückgängig (Z) und wiederholen (Y), Kosten in DNA, Bestätigen oder Abbrechen
  - `## Spielstände und Einstellungen`: drei Plätze, automatisches Speichern nach Editor und Größenwechsel, Lautstärke Musik und Effekte, Vollbild und Auflösung
  - `## Leistungstest und Vorführszenen`: Start mit `-- --benchmark` (Ergebnis in `leistungstest.txt` im Benutzerordner des Spiels) und mit `-- --szene=<name>`; alle acht Szenennamen aus `DemoScenes.SCENES` aufzählen
- Kurz und verständlich, höchstens etwa 80 Zeilen. Keine Datei unter `scripts/` ändern.

## Tests
`tests/test_doku_anleitung.gd` mit `extends "res://tests/base_test.gd"` und `const PATH := "res://docs/ANLEITUNG.md"`:
- `test_datei`: `FileAccess.file_exists(PATH)` wahr; `FileAccess.get_file_as_string(PATH).begins_with("# Zellenphase – Bedienungsanleitung")` wahr
- `test_abschnitte`: `var text := FileAccess.get_file_as_string(PATH)`; für jeden Eintrag aus `["## Spielstart", "## Steuerung", "## Ziel", "## Nahrung und Mundwerkzeuge", "## Zelleditor", "## Spielstände und Einstellungen", "## Leistungstest und Vorführszenen"]`: `text.contains(eintrag)` wahr
- `test_tasten`: `var text := FileAccess.get_file_as_string(PATH)`; für jeden Eintrag aus `["WASD", "Esc", "rechte Maustaste", "Filtermaul", "Kiefer", "Rüssel", "--benchmark"]`: `text.contains(eintrag)` wahr
- `test_szenen`: `var text := FileAccess.get_file_as_string(PATH)`; für jeden Namen `n` aus `DemoScenes.names()`: `text.contains(n)` wahr

Review (17.10.2026): gemergt.
