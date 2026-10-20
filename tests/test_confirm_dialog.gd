extends "res://tests/base_test.gd"

var dialog: ConfirmDialog

var ok_count := 0
var cancel_count := 0


func setup() -> void:
	dialog = ConfirmDialog.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(dialog)
	ok_count = 0
	cancel_count = 0
	dialog.confirmed.connect(func(): ok_count += 1)
	dialog.cancelled.connect(func(): cancel_count += 1)


func teardown() -> void:
	dialog.free()
	dialog = null


func test_anfangs_unsichtbar() -> void:
	check(not dialog.visible, "Dialog soll am Anfang unsichtbar sein")


func test_fragen() -> void:
	dialog.ask("Demo zurücksetzen?", "Zurücksetzen")
	check(dialog.visible, "Dialog soll sichtbar sein nach ask()")
	check_eq(dialog.question_label.text, "Demo zurücksetzen?", "Frage soll im Label stehen")
	check_eq(dialog.ok_button.text, "Zurücksetzen", "OK-Button soll 'Zurücksetzen' zeigen")


func test_bestaetigen() -> void:
	dialog.ask("X?")
	dialog.ok_button.pressed.emit()
	check_eq(ok_count, 1, "confirmed soll einmal ausgelöst sein")
	check_eq(cancel_count, 0, "cancelled darf nicht ausgelöst sein")
	check(not dialog.visible, "Dialog muss nach Bestätigung unsichtbar sein")


func test_abbrechen() -> void:
	dialog.ask("X?")
	dialog.cancel_button.pressed.emit()
	check_eq(cancel_count, 1, "cancelled soll einmal ausgelöst sein")
	check_eq(ok_count, 0, "confirmed darf nicht ausgelöst sein")
	check(not dialog.visible, "Dialog muss nach Abbrechen unsichtbar sein")


func test_standardtext() -> void:
	dialog.ask("X?")
	check_eq(dialog.ok_button.text, "Ja", "OK-Button soll Standardtext 'Ja' zeigen")


func test_karte_mit_schatten() -> void:
	var panel := dialog.box.get_theme_stylebox("panel") as StyleBoxFlat
	check(panel.shadow_size > 0, "Schattengröße muss größer 0 sein")
	check_eq(panel.content_margin_left, 32, "content_margin_left muss 32 sein")


func test_frage_zentriert() -> void:
	check(dialog.question_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Frage soll zentriert sein")
	check_eq(dialog.question_label.get_theme_font_size("font_size"), 34, "Schriftgröße muss 34 sein")
