extends "res://tests/base_test.gd"

var model: SceneModel
var session: EditorSession
var signal_count: int = 0


func setup() -> void:
	model = SceneModel.new()
	session = EditorSession.new(model)
	signal_count = 0
	session.selection_changed.connect(_on_changed)

	var o1: String = model.add_object("Node2D", "", {"name": "Welt"})
	var o2: String = model.add_object("Sprite2D", o1, {"name": "Spieler"})
	var o3: String = model.add_object("Camera2D", o1, {"name": "Kamera"})


func _on_changed(id: String) -> void:
	signal_count += 1


func test_auswahl() -> void:
	check(session.select("o2"), "select('o2') gibt true zurück")
	check_eq(session.selected, "o2", "selected ist 'o2'")
	check_eq(session.selected_object()["type"], "Sprite2D", "selected_object()['type'] ist Sprite2D")
	check_eq(signal_count, 1, "signal_count ist 1 nach erstem select")

	session.select("o2")
	check_eq(signal_count, 1, "signal_count bleibt 1 bei erneutem select('o2')")


func test_unbekannt() -> void:
	session.select("o2")
	check(not session.select("o9"), "select('o9') gibt false zurück")
	check_eq(session.selected, "o2", "selected bleibt 'o2' bei unbekannter Kennung")


func test_aufheben() -> void:
	session.select("o2")
	check(session.select(""), "select('') hebt Auswahl auf und gibt true zurück")
	check_eq(session.selected, "", "selected ist '' nach select('')")
	check(session.selected_object().is_empty(), "selected_object() ist leer nach Aufhebung")


func test_nach_loeschen() -> void:
	session.select("o2")
	var selected_before: String = session.selected
	model.remove_object("o2")
	session.validate()
	check_eq(session.selected, "", "selected ist '' nach validate() bei gelöschtem Objekt")
	check_eq(signal_count, 2, "signal_count ist 2 (1 für erste Auswahl, 1 für Aufhebung)")


func test_pfad() -> void:
	var path_o3: Array[String] = session.path_of("o3")
	check_eq(path_o3.size(), 2, "path_of('o3') hat 2 Elemente")
	check_eq(path_o3[0], "o1", "path_of('o3')[0] ist 'o1'")
	check_eq(path_o3[1], "o3", "path_of('o3')[1] ist 'o3'")

	var path_o1: Array[String] = session.path_of("o1")
	check_eq(path_o1, ["o1"], "path_of('o1') ist ['o1']")

	var path_o9: Array[String] = session.path_of("o9")
	check_eq(path_o9.size(), 0, "path_of('o9') ist leer")


func test_suche() -> void:
	var result1: Array[String] = session.search("spiel")
	check_eq(result1, ["o2"], "search('spiel') gibt ['o2'] zurück")

	var result2: Array[String] = session.search("2D")
	check_eq(result2.size(), 3, "search('2D') findet 3 Objekte")
	check("o1" in result2, "search('2D') enthält 'o1'")
	check("o2" in result2, "search('2D') enthält 'o2'")
	check("o3" in result2, "search('2D') enthält 'o3'")

	var result3: Array[String] = session.search("o3")
	check_eq(result3, ["o3"], "search('o3') gibt ['o3'] zurück")

	var result4: Array[String] = session.search("  ")
	check_eq(result4.size(), 0, "search('  ') gibt leere Liste zurück")
