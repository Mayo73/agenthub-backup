extends "res://tests/base_test.gd"

var bar: PerspectiveBar
var received_id := ""


func setup() -> void:
	bar = PerspectiveBar.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(bar)
	received_id = ""


func teardown() -> void:
	bar.free()


func _on_switched(id: String) -> void:
	received_id = id


func test_eintraege() -> void:
	bar.set_state(AppState.demo())
	check_eq(bar.picker.item_count, 8, "Einträge")
	check_eq(bar.picker.get_item_text(0), "Du bist: Alex (Jiu-Jitsu)", "Eintrag 0")
	check_eq(bar.picker.selected, 0, "ausgewählt")
	check(bar.tag_label.text.contains("DEMO"), "als Demo gekennzeichnet")


func test_wechsel_signal() -> void:
	bar.set_state(AppState.demo())
	bar.switched.connect(_on_switched)
	bar.picker.select(1)
	bar.picker.item_selected.emit(1)
	check_eq(received_id, "p02", "gewechselte ID")
