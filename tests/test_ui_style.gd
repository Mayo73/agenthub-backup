extends "res://tests/base_test.gd"

func test_icon_tab() -> void:
	var b := UiStyle.icon_tab("♥", "Matches")
	check(b.text == "♥\nMatches", "Text ist Symbol + Zeilenumbruch + Text")
	check(b.custom_minimum_size.y == 104, "Mindesthöhe ist 104")
	var sb := b.get_theme_stylebox("disabled")
	check(sb is StyleBoxFlat, "disabled ist StyleBoxFlat")
	check(sb.border_width_top == 5, "border_width_top ist 5")
	b.free()


func test_row_button() -> void:
	var b := UiStyle.row_button("Sam")
	check(b.alignment == HORIZONTAL_ALIGNMENT_LEFT, "alignment ist LEFT")
	check(b.custom_minimum_size.y == 104, "Mindesthöhe ist 104")
	var sb := b.get_theme_stylebox("normal") as StyleBoxFlat
	check(sb != null, "normal exists")
	check(sb.shadow_size > 0, "shadow_size größer 0")
	b.free()


func test_bubble() -> void:
	var l_mine := UiStyle.bubble("Hi", true)
	check(l_mine.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "mine=true → RIGHT")
	check(l_mine.size_flags_horizontal == Control.SIZE_SHRINK_END, "mine=true → SHRINK_END")
	var sb_mine := l_mine.get_theme_stylebox("normal") as StyleBoxFlat
	check(sb_mine.bg_color == UiStyle.ACCENT, "Mine-Farbe ist ACCENT")
	l_mine.free()

	var l_not_mine := UiStyle.bubble("Hi", false)
	check(l_not_mine.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT, "mine=false → LEFT")
	check(l_not_mine.size_flags_horizontal == Control.SIZE_SHRINK_BEGIN, "mine=false → SHRINK_BEGIN")
	var sb_not_mine := l_not_mine.get_theme_stylebox("normal") as StyleBoxFlat
	check(sb_not_mine.bg_color == UiStyle.RAISED, "Nicht-Mine-Farbe ist RAISED")
	l_not_mine.free()


func test_style_input() -> void:
	var e := LineEdit.new()
	UiStyle.style_input(e)
	check(e.custom_minimum_size.y == 72, "Mindesthöhe ist 72")
	var focus_sb := e.get_theme_stylebox("focus") as StyleBoxFlat
	check(focus_sb.border_color == UiStyle.ACCENT, "focus border color ist ACCENT")
	e.free()
