extends "res://tests/base_test.gd"

var canvas: CellEditorCanvas
var session: EditorSession
var history: EditorHistory


func setup() -> void:
	var u := PartUnlocks.new()
	u.unlock("geissel")
	session = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), u)
	history = EditorHistory.new()
	canvas = CellEditorCanvas.new()
	canvas.setup(session, history)


func teardown() -> void:
	canvas.free()


# Startaufbau: Filtermaul bei (1, 0) (Index 0), Knopfauge bei (0.4, 0) (Index 1).
# Bildschirmpunkt = (960, 540) + Lage × 260.

func test_einbauen_gespiegelt() -> void:
	canvas.place_id = "geissel"
	canvas.click(Vector2(752, 696))
	check_eq(session.working.parts.size(), 4, "Geißel und Spiegelbild eingebaut")
	check((session.working.parts[3]["pos"] as Vector2).is_equal_approx(Vector2(-0.8, -0.6)), "Spiegelbild bei (-0.8, -0.6)")
	check_eq(canvas.selected, 2, "erstes neues Teil ausgewählt")
	check(history.can_undo(), "Einbau steht im Verlauf")


func test_ohne_symmetrie() -> void:
	canvas.symmetry = false
	canvas.place_id = "geissel"
	canvas.click(Vector2(752, 696))
	check_eq(session.working.parts.size(), 3, "nur eine Geißel eingebaut")
	check_eq(canvas.selected, 2, "neues Teil ausgewählt")


func test_gesperrt() -> void:
	canvas.place_id = "stachel"
	canvas.click(Vector2(752, 696))
	check_eq(session.working.parts.size(), 2, "gesperrtes Teil nicht eingebaut")
	check(not history.can_undo(), "kein Verlaufseintrag ohne Änderung")


func test_auswaehlen() -> void:
	canvas.click(Vector2(1064, 540))
	check_eq(canvas.selected, 1, "Klick auf das Auge wählt es aus")
	canvas.click(Vector2(960, 740))
	check_eq(canvas.selected, -1, "Klick ins Leere hebt die Auswahl auf")


func test_ziehen_begrenzt() -> void:
	canvas.click(Vector2(1064, 540))
	canvas.begin_drag()
	canvas.drag_to(Vector2(1480, 540))
	check_eq(session.working.parts[1]["pos"], Vector2(1, 0), "Teil bleibt am Zellrand")
	check(history.can_undo(), "Verschieben steht im Verlauf")


func test_drehen() -> void:
	canvas.click(Vector2(1064, 540))
	canvas.rotate_selected(EditorPlacement.ANGLE_STEP)
	check_eq(session.working.parts[1]["angle"], PI / 8, "um einen Schritt gedreht")


func test_entfernen() -> void:
	var got: Array = []
	canvas.changed.connect(func() -> void: got.append(1))
	canvas.click(Vector2(1064, 540))
	canvas.remove_selected()
	check_eq(session.working.parts.size(), 1, "Auge entfernt")
	check_eq(canvas.selected, -1, "keine Auswahl mehr")
	check_eq(got.size(), 1, "changed einmal gemeldet")
	check_eq(history.undo(session.working).parts.size(), 2, "Rückgängig bringt das Auge zurück")
