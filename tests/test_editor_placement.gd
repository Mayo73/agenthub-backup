extends "res://tests/base_test.gd"

var progress: CellProgress

func setup() -> void:
	progress = CellProgress.new()


func test_umrechnen() -> void:
	var result1 := EditorPlacement.screen_to_local(Vector2(300, 200), Vector2(200, 200), 100.0)
	check_eq(result1, Vector2(1, 0), "screen_to_local")
	var result2 := EditorPlacement.local_to_screen(Vector2(0, -0.5), Vector2(200, 200), 100.0)
	check_eq(result2, Vector2(200, 150), "local_to_screen")


func test_am_koerper() -> void:
	var result1 := EditorPlacement.clamp_to_body(Vector2(2, 0))
	check_eq(result1, Vector2(1, 0), "clamp_to_body zu weit")
	var result2 := EditorPlacement.clamp_to_body(Vector2(0.3, 0.4))
	check_eq(result2, Vector2(0.3, 0.4), "clamp_to_body nah am Zentrum")


func test_auswahl() -> void:
	var b := CellBuild.starter(Diet.PFLANZENFRESSER)
	# Maul bei (1, 0), Auge bei (0.4, 0)
	check_eq(EditorPlacement.part_at(b, Vector2(0.95, 0.05)), 0, "Teil 0: Maul")
	check_eq(EditorPlacement.part_at(b, Vector2(0.42, 0)), 1, "Teil 1: Auge")
	check_eq(EditorPlacement.part_at(b, Vector2(-0.8, 0)), -1, "Kein Teil in der Nähe")


func test_einrasten() -> void:
	var result1 := EditorPlacement.snap_angle(0.4)
	check_eq(result1, PI / 8, "snap_angle auf 1 STEP")
	var result2 := EditorPlacement.snap_angle(-0.1)
	check_eq(result2, 0.0, "snap_angle auf 0")
