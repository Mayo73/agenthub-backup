extends "res://tests/base_test.gd"

var model: SceneModel
var kiste: String
var sprite: String
var clip: EditorClipboard


func setup() -> void:
	model = SceneModel.new()
	kiste = model.add_object("Node2D", "", {"name": "Kiste"})
	sprite = model.add_object("Sprite2D", kiste, {"textur": "kiste.png"})
	clip = EditorClipboard.new()


func test_kopieren() -> void:
	var count: int = clip.copy(model, [kiste])
	check_eq(count, 2, "soll 2 Objekte kopieren")


func test_einfuegen() -> void:
	clip.copy(model, [kiste])
	var roots: Array[String] = clip.paste(model)
	check_eq(roots.size(), 1, "soll 1 Wurzel-ID zurückgeben")
	check(not roots[0] == kiste, "neue ID soll ungleich original sein")

	var children: Array[String] = model.children(roots[0])
	check_eq(children.size(), 1, "Kindzahl soll 1 sein")

	var child_id: String = children[0]
	var obj: Dictionary = model.get_object(child_id)
	var t: String = obj["type"]
	check_eq(t, "Sprite2D", "Type soll Sprite2D sein")
	check_eq(obj["props"]["textur"], "kiste.png", "props[textur] soll kiste.png sein")

	check_eq(model.objects.size(), 4, "objects.size() soll 4 sein")


func test_zweimal() -> void:
	clip.copy(model, [kiste])
	clip.paste(model)
	clip.paste(model)
	check_eq(model.objects.size(), 6, "objects.size() soll 6 sein nach zweimal Einfügen")


func test_kind_doppelt() -> void:
	var count: int = clip.copy(model, [kiste, sprite])
	check_eq(count, 2, "soll 2 Einträge bei doppeltem Kopieren")


func test_leer() -> void:
	var fresh_clip := EditorClipboard.new()
	check(fresh_clip.is_empty(), "neue Zwischenablage soll empty sein")
	check_eq(fresh_clip.paste(model), [], "paste auf leerer Zwischenablage soll [] liefern")

	clip.copy(model, [kiste])
	check_eq(clip.paste(model, "o999"), [], "invalid parent_id soll [] liefern")
