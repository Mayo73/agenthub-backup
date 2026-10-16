extends "res://tests/base_test.gd"

var editor: CellEditor
var original: CellLook


func setup() -> void:
	editor = CellEditor.new()
	editor.open(CellBuild.starter(Diet.PFLANZENFRESSER), PartUnlocks.new(), CellProgress.new(), 0)
	original = CellLook.new()
	editor.set_look(original)


func teardown() -> void:
	editor.free()


func test_kopie() -> void:
	editor.set_color(Color.RED)
	check(editor.look.color.is_equal_approx(Color.RED), "Editor-Look hat Farbe ROT angenommen")
	check(original.color.is_equal_approx(CellLook.DEFAULT_COLOR), "Original-Color ist unverändert DEFAULT_COLOR")
	check(editor.canvas.look == editor.look, "canvas.look zeigt auf editor.look")


func test_farbknoepfe() -> void:
	check(editor.color_buttons.size() == 6, "Es gibt 6 Farbknöpfe")
	editor.color_buttons[1].pressed.emit()
	check(editor.look.color.is_equal_approx(CellEditor.COLORS[1]), "Farbe nach Klick auf zweiten Knopf stimmt mit COLORS[1] überein")


func test_muster() -> void:
	check(editor.pattern_option.item_count == 4, "Es gibt 4 Muster-Optionen")
	editor.pattern_option.item_selected.emit(2)
	check(editor.look.pattern == "streifen", "Nach Auswahl von Index 2 ist pattern 'streifen'")


func test_streckung() -> void:
	# Slider-Value setzen und Signal emittieren, damit set_stretch aufgerufen wird
	editor.stretch_slider.value = 1.4
	editor.stretch_slider.value_changed.emit(1.4)
	check(editor.look.stretch == 1.4, "Streckung wird über Slider auf 1.4 gesetzt")
	editor.set_stretch(3.0)
	check(editor.look.stretch == 1.5, "set_stretch(3.0) clampft auf MAX_STRETCH = 1.5")


func test_ohne_aussehen() -> void:
	var e := CellEditor.new()
	e.set_color(Color.RED)
	check(e.look == null, "Ohne set_look ist look = null und set_color macht nichts")
	e.free()
