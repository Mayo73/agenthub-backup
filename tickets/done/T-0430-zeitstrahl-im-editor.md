---
id: T-0430
title: Zeitstrahl oben im Zelleditor
project: zellenphase
priority: 4
after: T-0427, T-0429
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Im Zelleditor steht der Zeitstrahl oben über der Arbeitsfläche, damit man sieht, woher die Zelle kommt.

## Dateien
- `scripts/cell_editor.gd` – Zeitstrahl anzeigen
- `scripts/main.gd` – Zeitstrahl übergeben
- `tests/test_cell_editor.gd` – Test ergänzen

## Akzeptanzkriterien
- `cell_editor.gd`: `var timeline_view: TimelineView` (Name „Timeline“), im `panel` oben (`position = Vector2(24, 16)`, Höhe höchstens 150 px, `title_label` ausblenden); `func show_timeline(t: EvolutionTimeline) -> void` ruft `timeline_view.show_timeline(t)`
- `main.gd`: `open_editor()` ruft nach `editor.open(...)` `editor.show_timeline(timeline)`
- Andere Bedienelemente des Editors dürfen sich nicht mit der Leiste überdecken: liegt etwas im Bereich y < 170, nach unten schieben

## Tests
- `tests/test_cell_editor.gd` (gibt es die Datei nicht, neu anlegen; Editor mit `CellEditor.new()` anlegen, an `root` hängen, in `teardown()` freigeben): `test_zeitstrahl` (Zeitstrahl mit 2 Einträgen → `show_timeline` → `timeline_view.item_count()` 2)

Review (20.10.2026): gemergt, nachgebessert: Leiste ins Panel verschoben (lag unter dem Hintergrund), Zellansicht nicht mehr verschoben, Titel über use_compact() statt dauerhaft ausgeblendet.
