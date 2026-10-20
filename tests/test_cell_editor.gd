extends "res://tests/base_test.gd"

var editor: CellEditor
var timeline: EvolutionTimeline
var unlocks: PartUnlocks
var progress: CellProgress
var start: CellBuild


func setup() -> void:
	editor = CellEditor.new()
	timeline = EvolutionTimeline.new()
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


## Hilfsfunktion zum Hinzufügen von zwei Timeline-Einträgen.
func _add_two_timeline_entries() -> void:
	timeline.add_without_phase("start", "Start", Diet.PFLANZENFRESSER, 0.0, Color.WHITE)
	timeline.add_without_phase("stage", "Größe 1", Diet.PFLANZENFRESSER, 10.0, Color(0.5, 0.8, 0.3))


func test_zeitstrahl() -> void:
	_add_two_timeline_entries()
	editor.show_timeline(timeline)
	check_eq(editor.timeline_view.item_count(), 2, "timeline_item_count")


func test_fischknopf_gesperrt() -> void:
	editor.set_fish_ready(false, "Noch 2 Teile finden")
	check(editor.evolve_button.disabled, "evolve_button gesperrt")
	check_eq(editor.evolve_hint.text, "Noch 2 Teile finden", "evolve_hint Text")
	check(editor.evolve_hint.visible, "evolve_hint sichtbar")
	var got: Array = []
	editor.evolve_requested.connect(func(b: CellBuild) -> void: got.append(b))
	editor.evolve_button.pressed.emit()
	check_eq(got.size(), 0, "gesperrter Knopf sendet nichts")


func test_fischknopf_bereit() -> void:
	var got: Array = []
	var finished_got: Array = []
	editor.evolve_requested.connect(func(b: CellBuild) -> void: got.append(b))
	editor.finished.connect(func(b: CellBuild) -> void: finished_got.append(b))
	editor.set_fish_ready(true, "")
	check(not editor.evolve_hint.visible, "evolve_hint unsichtbar, wenn bereit")
	_place_geissel()
	editor.evolve_button.pressed.emit()
	check_eq(got.size(), 1, "evolve_requested gesendet")
	check_eq(got[0].parts.size(), 4, "Aufbau mit den neuen Teilen")
	check(editor.confirmed, "confirmed wahr")
	check_eq(finished_got.size(), 0, "finished nicht gesendet")


## Verwandlung zum Fisch: Zelle streckt sich, dann Blende ins Wasserblau, morph_finished genau einmal.
func test_verwandlung() -> void:
	var got: Array = []
	editor.morph_finished.connect(func() -> void: got.append(true))
	editor.play_morph()
	check(editor.evolve_button.disabled, "Knöpfe während der Verwandlung gesperrt")
	editor._process(1.0)
	check(editor.canvas.morph != null, "Ansicht zeigt die Verwandlung")
	check_eq(editor.fade_rect.color.a, 0.0, "noch keine Blende")
	editor._process(2.3)
	check_eq(got.size(), 1, "morph_finished einmal gesendet")
	check_eq(editor.fade_rect.color.a, 1.0, "ganz im Wasserblau")
	editor._process(1.0)
	check_eq(got.size(), 1, "morph_finished nicht noch einmal")


## Ohne play_morph tut _process nichts.
func test_ohne_verwandlung() -> void:
	var got: Array = []
	editor.morph_finished.connect(func() -> void: got.append(true))
	editor._process(5.0)
	check_eq(got.size(), 0, "kein morph_finished")
	check_eq(editor.fade_rect.color.a, 0.0, "keine Blende")
	check(editor.canvas.morph == null, "keine Verwandlung in der Ansicht")
