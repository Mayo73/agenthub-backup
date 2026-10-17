---
id: T-0135
title: Partnerruf im Spiel
project: zellenphase
priority: 3
after: T-0120, T-0117
---
## Ziel
Wie bei Spore bringt jeder neue Größenabschnitt einen Ruf. Mit Taste C oder der rechten Maustaste erscheint ein Partner vor der Zelle; wer ihn erreicht, öffnet den Zelleditor. In diesem Ticket hält die Zelle dann nur an (`editor_open`); den Editor selbst baut ein späteres Ticket ein.

## Dateien
- `scripts/partner_view.gd`: neu
- `scripts/controls.gd`
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/partner_view.gd` genau so:
```gdscript
class_name PartnerView
extends Node2D
## Zeichnet den gerufenen Partner (Platzhalter: Zelle mit pulsierendem Ring).

const COLOR := Color(0.5, 0.88, 0.82)
const RING_COLOR := Color(1.0, 0.6, 0.8)

var partner_pos: Variant = null
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	if partner_pos == null:
		return
	var pos := partner_pos as Vector2
	draw_circle(pos, MateCall.PARTNER_RADIUS, COLOR)
	draw_arc(pos, MateCall.PARTNER_RADIUS * (1.6 + 0.3 * sin(time * 3.0)), 0.0, TAU, 32, RING_COLOR, 2.0)
```
- `scripts/controls.gd`: `"rufen"` hinten an `ACTIONS` anhängen; in `setup()` als letzte Zeile `_add("rufen", [KEY_C], [MOUSE_BUTTON_RIGHT])`
- `scripts/main.gd`:
  - neue Variablen direkt unter `var pickup_view: PickupView`:
```gdscript
var mate := MateCall.new()
var partner_view: PartnerView
var editor_open := false
```
  - am Ende von `_ready()`:
```gdscript
	partner_view = PartnerView.new()
	partner_view.name = "Partner"
	world.add_child(partner_view)
```
  - `_physics_process`: ganz am Anfang (vor allen anderen Zeilen) `if editor_open:` mit eingerücktem `return`; als letzte Zeile `update_mate()`
  - in `feed_player()` im Block `if progress.eat(item.value):` nach `player.set_stage(progress.stage)` zwei Zeilen anhängen (gleiche Einrückung):
```gdscript
			mate.add_charge()
			hud.show_message("Neuer Ruf bereit: Taste C oder rechte Maustaste")
```
  - neue Funktionen am Ende:
```gdscript
## Ruf auslösen, beim Erreichen des Partners den Zelleditor öffnen, Partner zeichnen.
func update_mate() -> void:
	if Input.is_action_just_pressed("rufen"):
		call_mate()
	if mate.reached(player.position, player.radius):
		open_editor()
	partner_view.partner_pos = mate.partner_pos


func call_mate() -> bool:
	if mate.call_partner(player.position, player.motion.heading):
		hud.show_message("Ein Partner antwortet – schwimm zu ihm!")
		return true
	return false


## Öffnet den Zelleditor. Bis der Editor eingebaut ist, hält die Spielerzelle nur an.
func open_editor() -> void:
	editor_open = true
	player.input_enabled = false
	mate.finish()
```
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` anhängen:
- `test_ruf`: `main.call_mate()` falsch; `main.mate.add_charge()`; `main.call_mate()` wahr; `main.mate.partner_pos != null` wahr; `main.partner_view.get_parent() == main.world` wahr
- `test_wachstum_bringt_ruf`: `main.food.items.clear()`, `main.progress.eat(9)`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.mate.charges` ist 1
- `test_partner_erreicht`: `main.mate.add_charge()`, `main.call_mate()`, `main.player.position = main.mate.partner_pos`, `main.update_mate()` → `main.editor_open` wahr; `main.mate.partner_pos == null` wahr; `main.player.input_enabled` falsch; `main.partner_view.partner_pos == null` wahr
- `test_editor_haelt_spiel_an`: `main.editor_open = true`, `main._physics_process(0.016)` → `main.ai_cells.size()` ist 0
- `test_ruftaste`: `InputMap.has_action("rufen")` wahr

Review (16.10.2026): gemergt.
