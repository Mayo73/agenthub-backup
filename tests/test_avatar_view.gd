extends "res://tests/base_test.gd"

var view: AvatarView


func setup() -> void:
	view = AvatarView.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(view)


func teardown() -> void:
	view.free()


func test_initialen() -> void:
	check_eq(view.shown_initials(), "?", "ohne Profil zeigt view \"?\"")

	var profiles := DemoData.profiles()
	var first_profile := profiles[0]
	view.set_profile(first_profile)
	check_eq(view.shown_initials(), "A", "mit DemoData.profiles()[0] (Alex) zeigt view \"A\"")


func test_groesse() -> void:
	check_eq(view.custom_minimum_size, Vector2(160, 160), "Standard custom_minimum_size ist Vector2(160, 160)")

	view.set_diameter(96.0)
	check_eq(view.custom_minimum_size, Vector2(96, 96), "set_diameter(96) ändert custom_minimum_size zu Vector2(96, 96)")


func test_ringfarbe() -> void:
	view.profile = null
	check_eq(view.ring_color(), UiStyle.MUTED, "ohne Profil ist ring_color() UiStyle.MUTED")

	var profiles := DemoData.profiles()
	var first_profile := profiles[0]
	view.set_profile(first_profile)
	var expected := first_profile.color.lightened(0.3)
	check_eq(view.ring_color(), expected, "mit Profil ist ring_color() profile.color.lightened(0.3)")
