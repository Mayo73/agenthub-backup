extends "res://tests/base_test.gd"

var menu: SettingsMenu
var s: UserSettings


func setup() -> void:
	menu = SettingsMenu.new()
	s = UserSettings.new()


func teardown() -> void:
	menu.free()


func test_anzeige() -> void:
	s.set_music_volume(0.3)
	s.set_resolution_index(1)
	menu.show_settings(s)
	check(menu.visible, "Menü ist sichtbar")
	check_eq(menu.music_slider.value, 0.3, "Musik-Slider zeigt 0.3")
	check_eq(menu.resolution_option.selected, 1, "Auflösung-Option ausgewählt: 1")
	check_eq(menu.resolution_option.item_count, 4, "4 Auflösungsoptionen")
	check_eq(menu.resolution_option.get_item_text(2), "1920 × 1080", "Dritte Option ist 1920 × 1080")


func test_regler_schreiben() -> void:
	menu.show_settings(s)
	menu.music_slider.value_changed.emit(0.5)
	menu.sfx_slider.value_changed.emit(0.25)
	check_eq(s.music_volume, 0.5, "Music-Volume ist 0.5")
	check_eq(s.sfx_volume, 0.25, "SFX-Volmue ist 0.25")


func test_vollbild_und_aufloesung() -> void:
	menu.show_settings(s)
	menu.fullscreen_check.button_pressed = true
	menu.resolution_option.item_selected.emit(0)
	check(s.fullscreen, "Vollbild ist wahr")
	check_eq(s.resolution_index, 0, "Auflösungs-Index ist 0")


func test_zurueck() -> void:
	var got: Array = []
	menu.closed.connect(func() -> void: got.append(1))
	menu.show_settings(s)
	menu.back_button.pressed.emit()
	check_eq(got.size(), 1, "closed-Signal wurde gesendet")
	check(!menu.visible, "Menü ist unsichtbar")
