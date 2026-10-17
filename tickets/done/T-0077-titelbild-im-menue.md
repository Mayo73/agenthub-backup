---
id: T-0077
title: Titelbild als Hintergrund des Hauptmenüs
project: drift
priority: 3
after: A-0001, T-0070
---
## Ziel
Das Hauptmenü zeigt das Titelbild (Medien-Auftrag A-0001) als Hintergrund. Hinter der Knopfspalte liegt eine halbdurchsichtige dunkle Fläche, damit Titel und Knöpfe lesbar bleiben.

## Dateien
- `scenes/main_menu.tscn`
- `tests/test_main_menu.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Zeile direkt unter der vorhandenen `[ext_resource …]`-Zeile:
  `[ext_resource type="Texture2D" path="res://assets/menu/title_background.png" id="2_bg"]`
- Zwischen dem Block `[node name="Background" …]` und dem Block `[node name="Buttons" …]` zwei neue Knoten einfügen, genau in dieser Reihenfolge:
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

[node name="ButtonShade" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -190.0
offset_top = -270.0
offset_right = 190.0
offset_bottom = 270.0
mouse_filter = 2
color = Color(0, 0, 0, 0.5)
```
- Sonst nichts an der Szene ändern.

## Tests
In `tests/test_main_menu.gd` neue Methode `test_titelbild`:
- `var image := menu.get_node("BackgroundImage") as TextureRect` → `image != null`, `image.texture != null`
- `image.get_index() < menu.get_node("Buttons").get_index()` ist wahr
- `menu.get_node("ButtonShade") is ColorRect` ist wahr

Review (16.10.2026): gemergt.
