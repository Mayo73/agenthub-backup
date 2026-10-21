extends "res://tests/base_test.gd"

var model: SceneModel
var sprite_id: String

func setup() -> void:
	model = SceneModel.new()
	sprite_id = model.add_object("Sprite2D", "", {"textur": "held.png", "x": 3})
	model.add_object("Node2D")

func test_szene() -> void:
	var lines: Array[String] = PromptContext.scene_lines(model)
	check_eq(lines.size(), 3, "3 Zeilen")
	check(lines[0].begins_with("Szene: 2 Objekte"), "erste Zeile stimmt")

func test_zeile() -> void:
	var line: String = PromptContext.object_line(model, sprite_id)
	check(line.contains("Sprite2D"), "enthält Sprite2D")
	check(line.contains("textur=held.png"), "enthält textur=held.png")
	check(line.contains("x=3"), "enthält x=3")
	var textur_pos: int = line.find("textur")
	var x_pos: int = line.find("x=")
	check(textur_pos < x_pos, "textur steht vor x")

func test_auswahl_und_fehler() -> void:
	var lines: Array[String] = PromptContext.build(model, sprite_id, "Datei fehlt")
	var letzte: String = lines[-1]
	var vorletzte: String = lines[-2]
	check(vorletzte.begins_with("Ausgewählt: "), "vorletzte Zeile beginnt mit Ausgewählt: ")
	check(letzte == "Letzter Fehler: Datei fehlt", "letzte Zeile ist letzter Fehler")

func test_ohne_auswahl() -> void:
	var lines: Array[String] = PromptContext.build(model, "gibtsnicht")
	check_eq(lines.size(), 3, "3 Zeilen ohne Auswahl")

func test_begrenzt() -> void:
	var m: SceneModel = SceneModel.new()
	for i in range(40):
		m.add_object("Node2D")
	var lines: Array[String] = PromptContext.scene_lines(m)
	check_eq(lines.size(), 32, "32 Zeilen bei 40 Objekten")
	check(lines[-1].ends_with("… und 10 weitere"), "letzte Zeile: … und 10 weitere")
