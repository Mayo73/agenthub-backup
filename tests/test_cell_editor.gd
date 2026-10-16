extends "res://tests/base_test.gd"

var editor: CellEditor
var unlocks: PartUnlocks
var progress: CellProgress
var start: CellBuild


func setup() -> void:
	editor = CellEditor.new()
	unlocks = PartUnlocks.new()
	unlocks.unlock("geissel")
	progress = CellProgress.new()
	progress.eat(30)
	start = CellBuild.starter(Diet.PFLANZENFRESSER)
	editor.open(start, unlocks, progress, 0)


func teardown() -> void:
	editor.free()


## Hilfsfunktion zum Einfügen von zwei gespiegelten Geißeln.
func _place_geissel() -> void:
	editor.panel.select("geissel")
	editor.canvas.click(Vector2(752, 696))


func test_auswahl_geht_an_ansicht() -> void:
	editor.panel.select("geissel")
	check_eq(editor.canvas.place_id, "geissel", "place_id nach Auswahl")


func test_einbau_zeigt_kosten() -> void:
	_place_geissel()
	check_eq(editor.panel.cost_label.text, "Kosten: 30 DNA", "Kosten-Label")
	check(not editor.undo_button.disabled, "undo_enabled")
	check(editor.redo_button.disabled, "redo_disabled")


func test_rueckgaengig_wiederholen() -> void:
	_place_geissel()
	editor.undo()
	check_eq(editor.session.working.parts.size(), 2, "parts_nach_undo")
	check_eq(editor.panel.cost_label.text, "Kosten: 0 DNA", "kosten_nach_undo")
	check(not editor.redo_button.disabled, "redo_enabled_nach_undo")
	editor.redo()
	check_eq(editor.session.working.parts.size(), 4, "parts_nach_redo")


func test_bestaetigen() -> void:
	var got: Array = []
	editor.finished.connect(func(b: CellBuild) -> void: got.append(b))
	_place_geissel()
	editor.confirm()
	check_eq(got.size(), 1, "finished_emitted")
	check_eq(got[0].parts.size(), 4, "parts_nach_bestatigen")
	check_eq(progress.dna, 0, "dna_verrechnet")
	check(editor.confirmed, "confirmed_flag")


func test_zu_teuer() -> void:
	var got: Array = []
	editor.finished.connect(func(b: CellBuild) -> void: got.append(b))
	progress.dna = 10
	_place_geissel()
	editor.confirm()
	check_eq(got.size(), 0, "nicht_emittiert_bei_zu_wenig_dna")
	check_eq(progress.dna, 10, "dna_nicht_verrechnet")


func test_abbrechen() -> void:
	var got: Array = []
	editor.finished.connect(func(b: CellBuild) -> void: got.append(b))
	_place_geissel()
	editor.cancel()
	check_eq(got.size(), 1, "finished_emittiert")
	check(got[0] == start, "start_aufbau_zurueck")
	check_eq(progress.dna, 30, "dna_nicht_verrechnet")
	check(not editor.confirmed, "confirmed_falsch")


func test_symmetrie_schalter() -> void:
	var prev := editor.canvas.symmetry
	editor.symmetry_button.button_pressed = not prev
	check(editor.canvas.symmetry != prev, "symmetrie_gespiegelt")
