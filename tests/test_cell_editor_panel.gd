extends "res://tests/base_test.gd"

var panel: CellEditorPanel
var session: EditorSession
var progress: CellProgress


func setup() -> void:
	panel = CellEditorPanel.new()
	session = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), PartUnlocks.new())
	progress = CellProgress.new()
	progress.eat(20)
	panel.setup(session, progress, 0)


func teardown() -> void:
	panel.free()


func test_knoepfe() -> void:
	check_eq(panel.part_buttons.size(), 3, "Anzahl der Teile-Knöpfe")
	check(panel.part_buttons.has("kiefer"), "Knopf 'kiefer' existiert")
	check_eq(panel.part_buttons["kiefer"].text, "Kiefer (10)", "Text des Kiefer-Knopfs")
	check(not panel.part_buttons.has("geissel"), "geißel ist noch nicht freigeschaltet")


func test_werte() -> void:
	check_eq(panel.dna_label.text, "DNA: 20", "DNA-Anzeige")
	check_eq(panel.cost_label.text, "Kosten: 0 DNA", "Startkosten ohne Änderungen")
	check(not panel.confirm_button.disabled, "Bestätigen ist am Anfang aktiv")
	check(panel.preview_label.text.contains("Pflanzenfresser"), "Fähigkeitsvorschau zeigt Ernährungstyp")


func test_einbau() -> void:
	session.place("kiefer", Vector2(0.9, 0.3))
	panel.refresh()
	check_eq(panel.cost_label.text, "Kosten: 10 DNA", "Kosten nach Kiefer-Einbau")
	check(panel.preview_label.text.contains("Allesfresser"), "Fähigkeitsvorschau zeigt Allesfresser")


func test_rueckerstattung() -> void:
	session.working.remove_part(1)
	panel.refresh()
	check_eq(panel.cost_label.text, "Rückerstattung: 5 DNA", "Rückerstattung nach Teilentfernung")


func test_zu_teuer() -> void:
	progress.dna = 5
	session.place("kiefer", Vector2(0.9, 0.3))
	panel.refresh()
	check(panel.confirm_button.disabled, "Bestätigen gesperrt wenn DNA nicht reicht")


func test_auswahl() -> void:
	var got: Array = []
	panel.part_selected.connect(func(id: String) -> void: got.append(id))
	panel.select("kiefer")
	check_eq(panel.selected_id, "kiefer", "selected_id ist korrekt")
	check(panel.part_buttons["kiefer"].button_pressed, "Kiefer-Knopf ist gedrückt")
	check(not panel.part_buttons["knopfauge"].button_pressed, "Knopfauge-Knopf nicht gedrückt")
	check_eq(got.size(), 1, "Signal wurde einmal emittiert")
