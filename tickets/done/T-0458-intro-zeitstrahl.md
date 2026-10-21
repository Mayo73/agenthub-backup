---
id: T-0458
title: Übergangsbildschirm der Fischphase zeigt den Zeitstrahl
project: zellenphase
priority: 4
after: T-0457, T-0439, T-0454, T-0456
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Nach dem Übergang zum Fisch zeigt der Übergangsbildschirm (`FishIntro`) unter den bisherigen Zeilen den Zeitstrahl als schmale Leiste und den Rückblick.

## Dateien
- `scripts/fish_intro.gd` – Leiste und Rückblick
- `scripts/fish_main.gd` – Zeitstrahl übergeben
- `tests/test_fish_intro.gd` – Test ergänzen (gibt es die Datei nicht, neu anlegen; `FishIntro.new()` an `(Engine.get_main_loop() as SceneTree).root` hängen, in `teardown()` mit `free()` freigeben)

## Akzeptanzkriterien
Vorher `scripts/fish_intro.gd`, `scripts/timeline_view.gd` (`use_compact`) und `scripts/fish_main.gd` lesen.
- `fish_intro.gd`: `var timeline_view: TimelineView` (Name „Timeline“) unter `lines_box` in derselben Box, `use_compact(Vector2(1300, 144))`, `custom_minimum_size = Vector2(1300, 144)`
- `func show_timeline(t: EvolutionTimeline) -> void`: zeigt die Leiste (`timeline_view.show_timeline(t)`) und hängt an `lines_box` je Zeile aus `t.summary_lines()` ein Label (Schriftgröße 24) an; bei leerem Zeitstrahl bleibt die Leiste unsichtbar und es kommen keine Zeilen dazu
- `fish_main.gd`: direkt nach `intro.open(player.build)` `intro.show_timeline(timeline)`

## Tests
- `tests/test_fish_intro.gd`: `test_zeitstrahl` (Zeitstrahl mit 2 Einträgen → `show_timeline` → `timeline_view.item_count()` 2, `timeline_view.visible` wahr, ein Label in `lines_box` hat den Text „Entwicklungsschritte: 2“); `test_leer` (leerer Zeitstrahl → `timeline_view.visible` falsch)

Review (21.10.2026): gemergt, nachgebessert: Mindestgröße 1300 × 144 nur für die Leiste, nicht für die ganze Box.
