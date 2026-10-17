---
id: T-0078
title: Bild des gewählten Autos im Hauptmenü
project: drift
priority: 3
after: T-0077, T-0071
---
## Ziel
Unter der Autowahl im Hauptmenü erscheint das Bild des gewählten Autos und wechselt mit der Auswahl.

## Dateien
- `scenes/main_menu.tscn`
- `scripts/main_menu.gd`
- `tests/test_main_menu.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scenes/main_menu.tscn`: direkt nach dem Block `[node name="CarNext" …]` (also nach der ganzen `CarRow`) einen neuen Knoten einfügen:
```
[node name="CarPreview" type="TextureRect" parent="Buttons"]
custom_minimum_size = Vector2(0, 64)
layout_mode = 2
expand_mode = 1
stretch_mode = 5
```
  Außerdem im Block `[node name="Buttons" …]` `offset_top = -240.0` zu `offset_top = -280.0` und `offset_bottom = 240.0` zu `offset_bottom = 280.0` ändern. Sonst nichts an der Szene ändern.
- `scripts/main_menu.gd`: neue Zeile direkt unter `@onready var car_next …`: `@onready var car_preview: TextureRect = $Buttons/CarPreview`. In `update_car_label()` als letzte Zeile: `car_preview.texture = load(CarCatalog.sprite_of(GameSettings.car_id)) as Texture2D`

## Tests
In `tests/test_main_menu.gd` neue Methode `test_autobild`:
- `menu.car_preview.texture != null`
- `menu._on_car_next()` aufrufen → `menu.car_preview.texture.resource_path` ist gleich `CarCatalog.sprite_of(GameSettings.car_id)`

Review (16.10.2026): gemergt.
