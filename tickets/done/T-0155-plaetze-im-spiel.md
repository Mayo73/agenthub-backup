---
id: T-0155
title: Spielstandplätze im Hauptmenü
project: zellenphase
priority: 3
after: T-0152, T-0154
---
## Ziel
„Neue Partie“ und „Fortsetzen“ fragen jetzt nach einem der drei Spielstandplätze. Danach wird in diesem Platz gespeichert (Lastenheft Soll „mehrere lokale Spielstände“). Die bisherigen Funktionen `_on_new_game` und `_on_continue` bleiben unverändert und werden nach der Auswahl aufgerufen.

## Dateien
- `scripts/main.gd`
- `tests/test_main_plaetze.gd`: neu

## Akzeptanzkriterien
- Neue Variablen direkt unter `var hints := TutorialHints.new()`:
```gdscript
var slot_prefix := SaveSlots.PREFIX
var slot_menu: SlotMenu
## Ernährung der gewünschten neuen Partie; "" = Fortsetzen.
var pending_diet := ""
```
- In `_ready()` die Zeile `main_menu.new_game.connect(_on_new_game)` ersetzen durch `main_menu.new_game.connect(ask_slot_new)` und `main_menu.continue_game.connect(_on_continue)` durch `main_menu.continue_game.connect(ask_slot_continue)`.
- In `_ready()` **und** in `back_to_menu()` die Zeile `main_menu.set_can_continue(FileAccess.file_exists(save_path))` jeweils ersetzen durch `main_menu.set_can_continue(SaveSlots.first_used(slot_prefix) > 0)`.
- Am Ende von `_ready()`:
```gdscript
	slot_menu = SlotMenu.new()
	slot_menu.name = "SlotMenu"
	add_child(slot_menu)
	slot_menu.slot_chosen.connect(_on_slot_chosen)
	add_click_sounds(slot_menu)
```
- Neue Funktionen am Ende:
```gdscript
func ask_slot_new(diet: String) -> void:
	pending_diet = diet
	slot_menu.prefix = slot_prefix
	slot_menu.open("Neue Partie – Platz wählen", false)


func ask_slot_continue() -> void:
	pending_diet = ""
	slot_menu.prefix = slot_prefix
	slot_menu.open("Fortsetzen – Spielstand wählen", true)


func _on_slot_chosen(slot: int) -> void:
	save_path = SaveSlots.path_for(slot, slot_prefix)
	if pending_diet != "":
		_on_new_game(pending_diet)
		autosave_now()
	else:
		_on_continue()
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_plaetze.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_main_platz_"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.slot_prefix = P`; `teardown()`: `main.free()` und für `slot` von 1 bis 3 die Datei `SaveSlots.path_for(slot, P)` löschen, falls vorhanden.
- `test_neue_partie_fragt`: `main.main_menu.herbivore_button.pressed.emit()` → `main.slot_menu.visible` wahr; `main.in_menu` wahr
- `test_neue_partie_im_platz`: `main.ask_slot_new(Diet.FLEISCHFRESSER)`, `main.slot_menu.slot_buttons[1].pressed.emit()` → `main.in_menu` falsch; `main.player.diet` ist `Diet.FLEISCHFRESSER`; `main.save_path` ist `SaveSlots.path_for(2, P)`; `FileAccess.file_exists(SaveSlots.path_for(2, P))` wahr
- `test_fortsetzen`: `main.ask_slot_new(Diet.PFLANZENFRESSER)`, `main.slot_menu.slot_buttons[0].pressed.emit()`, `main.progress.dna = 9`, `main.save_now()`, `main.back_to_menu()`, `main.progress.dna = 0`, `main.ask_slot_continue()`, `main.slot_menu.slot_buttons[0].pressed.emit()` → `main.progress.dna` ist 9; `main.in_menu` falsch
- `test_fortsetzen_moeglich`: `main.ask_slot_new(Diet.PFLANZENFRESSER)`, `main.slot_menu.slot_buttons[2].pressed.emit()`, `main.back_to_menu()` → `main.main_menu.continue_button.disabled` falsch

Review (17.10.2026): gemergt.
