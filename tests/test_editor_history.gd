extends "res://tests/base_test.gd"

var h: EditorHistory
var b: CellBuild

func setup() -> void:
	h = EditorHistory.new()
	b = CellBuild.starter(Diet.PFLANZENFRESSER)


func test_leer() -> void:
	check(not h.can_undo(), "keine Rückgängig-Möglichkeiten am Anfang")
	check(h.undo(b) == null, "undo bei leerer Liste liefert null")
	check(h.redo(b) == null, "redo bei leerer Liste liefert null")


func test_rueckgaengig() -> void:
	h.record(b)
	b.add_part("kiefer", Vector2(0.9, 0.3))
	var back := h.undo(b)
	check(back.parts.size() == 2, "undo liefert Zustand vor add_part (Größe 2)")
	check(h.can_redo(), "can_redo wahr nach undo")
	var fwd := h.redo(back)
	check(fwd.parts.size() == 3, "redo liefert Zustand mit add_part (Größe 3)")
	check(h.can_undo(), "can_undo wahr nach redo")


func test_neue_aenderung_leert_redo() -> void:
	h.record(b)
	b.add_part("kiefer", Vector2(0.9, 0.3))
	var back := h.undo(b)
	h.record(back)
	check(not h.can_redo(), "neue record nach undo leert Redo-Liste")


func test_grenze() -> void:
	for i in 60:
		h.record(b)
	var n := 0
	while h.can_undo():
		h.undo(b)
		n += 1
	check(n == 50, "MAX_STEPS=50 begrenzt Undo-Liste (60 records ergeben 50 undo)")


func test_leeren() -> void:
	h.record(b)
	h.clear()
	check(not h.can_undo(), "clear leert alle Historie")
