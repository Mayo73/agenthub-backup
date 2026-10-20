---
id: T-0427
title: TimelineView – Leiste mit einem Bild je Entwicklungsschritt
project: zellenphase
priority: 4
after: T-0426
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Eine Leiste zeigt die Einträge einer `EvolutionTimeline` nebeneinander, je ein kleines Bild der Lebensform mit farbigem Rand nach Ernährung und dem Zeitpunkt darunter.

## Dateien
- `scripts/timeline_view.gd` – neu, Klasse `TimelineView`
- `tests/test_timeline_view.gd` – neu

## Akzeptanzkriterien
`class_name TimelineView`, `extends Control`. Bedienelemente im Code anlegen (siehe Projektregeln).
- `const ITEM_SIZE := Vector2(96, 120)`, `const GAP := 12.0`
- `var timeline: EvolutionTimeline`, `var strip: HBoxContainer` (Name „Strip“, Abstand `GAP`), `var title_label: Label` (Text „Deine Entwicklung“), `var stats_label: Label` (zunächst leer)
- `func show_timeline(t: EvolutionTimeline) -> void`: leert `strip` (Kinder mit `free()` entfernen) und legt je Eintrag ein Element an (eigene Klasse `TimelineItem extends Control` in `scripts/timeline_item.gd`), Größe `custom_minimum_size = ITEM_SIZE`
- `TimelineItem` hat `var entry: Dictionary` und zeichnet in `_draw()`: Rahmen in `EvolutionTimeline.diet_color(entry["diet"])` (Breite 4), darin bei `phase == "zelle"` einen Kreis in `entry["color"]`, bei `"fisch"` eine Ellipse (Polygon aus 24 Punkten, doppelt so breit wie hoch) in `entry["color"]`; darunter zwei `Label`-Kinder mit `entry["label"]` und `EvolutionTimeline.time_text(entry["time"])`
- `func show_stats(lines: Array[String]) -> void`: `stats_label.text` = Zeilen mit `"\n"` verbunden
- `func item_count() -> int`: Anzahl der Elemente in `strip`

## Tests
`tests/test_timeline_view.gd` (Ansicht mit `TimelineView.new()` anlegen, an `(Engine.get_main_loop() as SceneTree).root` hängen, in `teardown()` mit `free()` freigeben):
- `test_eintraege`: Zeitstrahl mit 3 Einträgen → `item_count()` 3
- `test_neu_zeigen`: erst 3, dann ein Zeitstrahl mit 1 Eintrag → `item_count()` 1
- `test_statistik`: `show_stats(["a", "b"])` → `stats_label.text` „a\nb“
- `test_titel`: `title_label.text` „Deine Entwicklung“

Review (20.10.2026): gemergt, nachgebessert: Layout der Ansicht (VBox, Abstand als Theme-Konstante, Beschriftungen fest unter dem Bild), leere Datei run_tests.gd.py entfernt.
