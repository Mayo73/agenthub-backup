---
id: T-0079
title: Titelbild auch im Einstellungsmenü
project: drift
priority: 5
after: A-0001, T-0064
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Das Einstellungsmenü bekommt denselben Hintergrund wie das Hauptmenü: Titelbild plus halbdurchsichtige dunkle Fläche hinter den Einträgen.

## Dateien
- `scenes/settings_menu.tscn`
- `tests/test_settings_menu.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Zeile direkt unter der vorhandenen `[ext_resource …]`-Zeile:
  `[ext_resource type="Texture2D" path="res://assets/menu/title_background.png" id="2_bg"]`
- Zwischen dem Block `[node name="Background" …]` und dem Block `[node name="Items" …]` zwei neue Knoten einfügen, genau in dieser Reihenfolge:
```
[node name="BackgroundImage" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
texture = ExtResource("2_bg")
expand_mode = 1
stretch_mode = 6

[node name="ItemShade" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -230.0
offset_top = -350.0
offset_right = 230.0
offset_bottom = 350.0
mouse_filter = 2
color = Color(0, 0, 0, 0.5)
```
- Sonst nichts an der Szene ändern.

## Tests
In `tests/test_settings_menu.gd` neue Methode `test_hintergrundbild`:
- `var image := menu.get_node("BackgroundImage") as TextureRect` → `image != null`, `image.texture != null`
- `image.get_index() < menu.get_node("Items").get_index()` ist wahr
- `menu.get_node("ItemShade") is ColorRect` ist wahr

Review (16.10.2026): gemergt.
