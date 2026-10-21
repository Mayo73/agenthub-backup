---
id: T-0502
title: Treffen – Ortsskizze kompakter, Beschriftung mit Innenabstand
project: sparring
priority: 2
---
## Ziel
Befund aus P-0014: Die Ortsskizze im Treffvorschlag ist recht groß und schiebt das Datum an den Bildrand; die Beschriftung „Skizze: draußen (schematisch, keine Karte)“ klebt am unteren Rand der Fläche. Die Skizze wird niedriger, die Beschriftung bekommt eine eigene Zeile mit Abstand unter der Fläche. Die Kennzeichnung als schematisch bleibt.

## Dateien
- `scripts/meeting_screen.gd` – Höhe der Skizze
- `scripts/place_view.gd` – Beschriftung
- `tests/test_place_view.gd`, `tests/test_meeting_screen.gd` – Tests ergänzen (bestehende nicht ändern; gibt es `tests/test_place_view.gd` nicht, neu anlegen)

## Akzeptanzkriterien
- `meeting_screen.gd`: `place_view.custom_minimum_size = Vector2(0, 160)` statt 260.
- `place_view.gd`: `const CAPTION_HEIGHT := 40`. `caption_label` liegt nicht mehr über der Zeichnung: Anker unten über die ganze Breite, aber mit `offset_left = 12`, `offset_right = -12`, `offset_top = -CAPTION_HEIGHT`, `offset_bottom = -8`, `vertical_alignment = VERTICAL_ALIGNMENT_CENTER`. In `_draw()` endet die gezeichnete Fläche `CAPTION_HEIGHT` Pixel über dem unteren Rand (die Höhe, die `_draw()` für Himmel/Wiese usw. verwendet, um `CAPTION_HEIGHT` verringern; vorher lesen).
- `shape_count()` und `set_place()` verhalten sich wie bisher.

## Tests
- `tests/test_place_view.gd`, `test_beschriftung_mit_abstand`: `var v := PlaceView.new()` → `v.caption_label.offset_left` 12, `v.caption_label.offset_top` `-PlaceView.CAPTION_HEIGHT`, `v.caption_label.offset_bottom` -8; `v.free()`.
- `tests/test_meeting_screen.gd`, `test_skizze_kompakt`: `screen.place_view.custom_minimum_size.y` 160.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0502 erhalten.
