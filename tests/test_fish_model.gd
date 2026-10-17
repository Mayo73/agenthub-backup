extends "res://tests/base_test.gd"

var model: FishModel


func setup() -> void:
	model = FishModel.new()


func teardown() -> void:
	model.free()


func test_grundform() -> void:
	check_eq(model.get_child_count(), 6, "6 Kinder (Body, TailPivot, FinL, FinR, EyeL, EyeR)")
	check(model.jaw == null, "kein Kiefer bei start")
	check_eq(model.spikes.size(), 0, "keine Stacheln bei start")
	check_eq(model.body.scale, Vector3(0.5, 0.6, 1.6), "Körpergröße entspricht Basis")
	check(model.get_node("TailPivot/Tail") is MeshInstance3D, "Schwanz ist MeshInstance3D")


func test_masse() -> void:
	var b := FishBuild.new()
	b.upgrade("schwanz")
	b.upgrade("flossen")
	b.upgrade("flossen")
	var s := FishModel.shape(b)
	check_eq(s["tail"], 0.75, "Schwanzhöhe")
	check_eq(s["fins"], 0.7, "Flossenlänge")
	check_eq(s["jaw"], 0.0, "kein Kiefer")
	check_eq(s["spikes"], 0, "keine Stacheln")
	check_eq(s["eyes"], 0.08, "Augenradius")


func test_kiefer_und_stacheln() -> void:
	var b := FishBuild.new()
	b.upgrade("kiefer")
	b.upgrade("stacheln")
	b.upgrade("stacheln")
	model.rebuild(b)
	check(model.jaw != null, "Kiefer vorhanden")
	check_eq(model.spikes.size(), 4, "4 Stacheln")
	check_eq(model.get_child_count(), 11, "11 Kinder")
	check(model.build == b, "build entspricht b")


func test_flossen_wachsen() -> void:
	var b := FishBuild.new()
	b.upgrade("flossen")
	model.rebuild(b)
	check_eq((model.fins[0].mesh as BoxMesh).size.x, 0.5, "Brustflosse gewachsen")


func test_farbe() -> void:
	var b := FishBuild.new()
	b.color = Color(0.9, 0.3, 0.2)
	model.rebuild(b)
	check((model.body.material_override as StandardMaterial3D).albedo_color.is_equal_approx(Color(0.9, 0.3, 0.2)), "Körperfarbe")


func test_schwanzschlag() -> void:
	check_eq(FishModel.tail_angle(0.0, 3.0), 0.0, "Schwanzwinkel bei t=0")
	model.animate(0.1, 0.0)
	check_eq(model.tail_pivot.rotation.y, sin(0.4) * 0.35, "Schwanzschlag nach Animation")
