---
id: T-0174
title: Partner sieht aus wie die eigene Zelle
project: zellenphase
priority: 2
after: T-0158, T-0166
---
## Ziel
Wie bei Spore sieht der gerufene Partner aus wie die eigene Zelle (Farbe, Muster, Form, gleiche Größe) statt wie ein einfacher Kreis. Erreicht ist er, sobald sich die beiden Zellen berühren.

## Dateien
- `scripts/partner_view.gd`
- `scripts/main.gd`
- `tests/test_main_partner.gd`: neu

## Akzeptanzkriterien
- `scripts/partner_view.gd`:
  - Neue Variablen direkt unter `var time := 0.0`:
```gdscript
var look := CellLook.new()
var radius := MateCall.PARTNER_RADIUS
```
  - In `_draw()` die Zeile `draw_circle(pos, MateCall.PARTNER_RADIUS, COLOR)` ersetzen durch `CellPainter.draw_cell(self, pos, look, radius, time)` und in der Zeile mit `draw_arc` den Ausdruck `MateCall.PARTNER_RADIUS * (1.6 + 0.3 * sin(time * 3.0))` durch `radius * (1.6 + 0.3 * sin(time * 3.0))` ersetzen.
- `scripts/main.gd`, Funktion `update_mate()`:
  - Die Zeile `if mate.reached(player.position, player.radius):` ersetzen durch `if mate.reached(player.position, player.radius * 2.0 - MateCall.PARTNER_RADIUS):` (der Partner ist so groß wie die Spielerzelle; erreicht bei Berührung)
  - Direkt vor der Zeile `partner_view.partner_pos = mate.partner_pos` zwei Zeilen:
```gdscript
	partner_view.look = player.look
	partner_view.radius = player.radius
```
- Sonst nichts an beiden Dateien ändern.

## Tests
`tests/test_main_partner.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_partner_wie_spieler`: `var l := CellLook.new()`, `l.color = Color.RED`, `main.player.set_look(l)`, `main.mate.add_charge()`, `main.call_mate()`, `main.update_mate()` → `main.partner_view.look == l` wahr; `main.partner_view.radius` ist `main.player.radius`
- `test_beruehrung_reicht`: `main.player.set_stage(3)`, `main.mate.add_charge()`, `main.call_mate()`, `main.player.position = (main.mate.partner_pos as Vector2) + Vector2(main.player.radius * 1.9, 0)`, `main.update_mate()` → `main.editor_open` wahr; danach `main.editor.cancel()`
- `test_zu_weit`: `main.mate.add_charge()`, `main.call_mate()`, `main.player.position = (main.mate.partner_pos as Vector2) + Vector2(main.player.radius * 2.5, 0)`, `main.update_mate()` → `main.editor_open` falsch

Review (17.10.2026): gemergt.
