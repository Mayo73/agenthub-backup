---
id: T-0063
title: Tastenbelegung im Einstellungsmenü
project: drift
priority: 3
after: T-0050, T-0062
---
## Ziel
Im Einstellungsmenü steht für jede Aktion eine Zeile mit Namen und Taste. Klick auf die Taste, dann eine neue Taste drücken: Sie gilt sofort und wird mit „Zurück“ gespeichert. Esc bricht ab.

## Dateien
- `scenes/settings_menu.tscn`
- `scripts/settings_menu.gd`
- `tests/test_settings_menu.gd`: `teardown()` ergänzen und Tests anhängen, bestehende Tests nicht ändern

## Akzeptanzkriterien
- `scenes/settings_menu.tscn`: im Block `[node name="Items" …]` `offset_top = -150.0` durch `offset_top = -330.0` und `offset_bottom = 150.0` durch `offset_bottom = 330.0` ersetzen. Sonst nichts an der Szene ändern.
- `scripts/settings_menu.gd`:
  - neue Variablen `var key_buttons := {}` (Aktion → Button) und `var waiting_action := ""`
  - in `_ready()` direkt nach `settings = UserSettings.load_from(settings_path)` drei Zeilen: `Controls.setup()`, `Controls.apply_bindings(settings.keys)`, `_build_key_rows()`
  - neue Funktionen am Ende der Datei:
```gdscript


## Eine Zeile je Aktion: Name und Knopf mit der aktuellen Taste, vor „Zurück“.
func _build_key_rows() -> void:
	var grid := GridContainer.new()
	grid.name = "Keys"
	grid.columns = 2
	$Items.add_child(grid)
	$Items.move_child(grid, back_button.get_index())
	for action in Controls.ACTIONS:
		var label := Label.new()
		label.text = Controls.LABELS[action]
		label.custom_minimum_size = Vector2(200, 0)
		grid.add_child(label)
		var button := Button.new()
		button.name = action
		button.custom_minimum_size = Vector2(180, 0)
		button.text = Controls.key_name(Controls.key_for(action))
		button.pressed.connect(start_rebind.bind(action))
		grid.add_child(button)
		key_buttons[action] = button


## Wartet auf die nächste Taste für `action`.
func start_rebind(action: String) -> void:
	waiting_action = action
	key_buttons[action].text = "Taste drücken …"


## Übernimmt die gedrückte Taste; Esc bricht ab.
func handle_key(keycode: int) -> void:
	if waiting_action == "":
		return
	var action := waiting_action
	waiting_action = ""
	if keycode != KEY_ESCAPE:
		Controls.rebind_key(action, keycode)
		settings.keys[action] = keycode
	key_buttons[action].text = Controls.key_name(Controls.key_for(action))


func _input(event: InputEvent) -> void:
	if waiting_action != "" and event is InputEventKey and event.pressed and not event.echo:
		handle_key(event.physical_keycode)
		get_viewport().set_input_as_handled()
```

## Tests
In `tests/test_settings_menu.gd`:
- in `teardown()` zusätzlich `Controls.reset_defaults()`
- `test_tasten_angezeigt`: `menu.key_buttons.size()` ist `Controls.ACTIONS.size()`; `menu.key_buttons["gas"].text` ist `"W"`; `menu.get_node("Items/Keys") is GridContainer` ist wahr
- `test_taste_neu_belegen`: `menu.start_rebind("gas")` → `menu.key_buttons["gas"].text` ist `"Taste drücken …"`; dann `menu.handle_key(KEY_I)` → `Controls.key_for("gas")` ist `KEY_I`, `menu.settings.keys["gas"]` ist `KEY_I`, `menu.key_buttons["gas"].text` ist `"I"`, `menu.waiting_action` ist `""`
- `test_escape_bricht_ab`: `menu.start_rebind("gas")`, `menu.handle_key(KEY_ESCAPE)` → `Controls.key_for("gas")` ist `KEY_W`; `menu.settings.keys.has("gas")` ist falsch; `menu.key_buttons["gas"].text` ist `"W"`

Review (16.10.2026): gemergt.
