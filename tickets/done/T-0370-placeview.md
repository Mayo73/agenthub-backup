---
id: T-0370
title: PlaceView – schematische Ortsskizze zeichnen (2. Anlauf)
project: sparring
priority: 3
after: T-0357
---
## Ziel
Meilenstein „Ortsskizze“: Ein kleines Bedienelement zeichnet die Formen aus `PlaceSketch` (T-0357) selbst, mit einer Beschriftung, dass es nur eine Skizze und keine Karte ist. Kein externer Kartendienst, keine Bilder.

## Dateien
- `scripts/place_view.gd` – neu, Klasse `PlaceView`
- `tests/test_place_view.gd` – neu

## Akzeptanzkriterien
`class_name PlaceView`, `extends Control`:
- `var kind := "Draußen"`
- `var caption_label: Label` – im `_init()` angelegt mit `UiStyle.label(PlaceSketch.caption("Draußen"), UiStyle.SIZE_SMALL, UiStyle.TEXT)`, unten an der Fläche (`set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)`), als Kind hinzugefügt
- `_init()`: `custom_minimum_size = Vector2(0, 220)`
- `func set_place(place: String) -> void`: `kind = PlaceSketch.kind_for(place)`, `caption_label.text = PlaceSketch.caption(kind)`, `queue_redraw()`
- `func shape_count() -> int`: `PlaceSketch.shapes(kind).size()`
- `func _draw() -> void`: für jede Form aus `PlaceSketch.shapes(kind)`: `rect` → `draw_rect(Rect2(pos * size, s * size), color)` (mit `size` = Größe des Controls); `circle` → `draw_circle(pos * size, radius * size.x, color)`
- Die Farben kommen aus `PlaceSketch` (Ausnahme von der Regel „Farben nur über `UiStyle`“, weil es Zeichnungsdaten sind).

## Tests
`tests/test_place_view.gd`: in `setup()` `view = PlaceView.new()`, an `(Engine.get_main_loop() as SceneTree).root` hängen, `view.size = Vector2(400, 220)`; `teardown()` `view.free()`.
- `test_anfang`: `kind` „Draußen“, `caption_label.text` enthält „keine Karte“, `shape_count()` 2
- `test_park`: `set_place("Stadtpark")` → `kind` „Park“, `shape_count()` 5, `caption_label.text` „Skizze: Park (schematisch, keine Karte)“
- `test_wechsel`: `set_place("Strand")`, dann `set_place("")` → `kind` „Draußen“
- `test_mindesthoehe`: `custom_minimum_size.y` 220
- `test_beschriftung_ist_kind`: `caption_label.get_parent() == view`

## Hinweise aus dem ersten Anlauf (T-0358)
- **`scripts/place_sketch.gd` und `tests/test_place_sketch.gd` nicht ändern.** Sie sind fertig (T-0357) und ihre Tests sind grün; im ersten Anlauf wurden sie umgebaut und dadurch rot. Nur `scripts/place_view.gd` und `tests/test_place_view.gd` neu anlegen und nur die vorhandenen Funktionen `PlaceSketch.kind_for()`, `PlaceSketch.caption()` und `PlaceSketch.shapes()` benutzen.
- Rückgabe von `shapes()` ist ein Array von Dictionaries; Größe der Form als `shape["size"]` lesen (Schlüssel), nicht `shape.size` (das ist bei Dictionaries die Methode).

Review (19.10.2026): gemergt.
