class_name CellEditor
extends Node
## Zelleditor: verbindet Bedienleiste, Zellansicht und Verlauf. main.gd öffnet ihn nach dem Partnerfund.

## Neuer Aufbau nach Bestätigen, unveränderter Aufbau nach Abbrechen.
signal finished(build: CellBuild)

const COLORS := [Color("#7FE0D0"), Color("#6CCB5F"), Color("#E0C060"), Color("#D98FE0"), Color("#E07F7F"), Color("#7FA8E0")]

var session: EditorSession
var history := EditorHistory.new()
var progress: CellProgress
var confirmed := false
var panel: CellEditorPanel
var view_layer: CanvasLayer
var canvas: CellEditorCanvas
var tools: HBoxContainer
var undo_button: Button
var redo_button: Button
var symmetry_button: CheckButton
var look: CellLook
var look_box: VBoxContainer
var color_buttons: Array[Button] = []
var pattern_option: OptionButton
var stretch_slider: HSlider


func _init() -> void:
	view_layer = CanvasLayer.new()
	view_layer.name = "View"
	view_layer.layer = 4
	add_child(view_layer)
	var background := ColorRect.new()
	background.color = Color("#0B2B3D")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view_layer.add_child(background)
	canvas = CellEditorCanvas.new()
	canvas.name = "Canvas"
	view_layer.add_child(canvas)
	panel = CellEditorPanel.new()
	panel.name = "Panel"
	add_child(panel)
	tools = HBoxContainer.new()
	tools.name = "Tools"
	tools.position = Vector2(24, 990)
	panel.add_child(tools)
	undo_button = Button.new()
	undo_button.text = "Rückgängig"
	tools.add_child(undo_button)
	redo_button = Button.new()
	redo_button.text = "Wiederholen"
	tools.add_child(redo_button)
	symmetry_button = CheckButton.new()
	symmetry_button.text = "Symmetrie"
	symmetry_button.button_pressed = true
	tools.add_child(symmetry_button)
	undo_button.pressed.connect(undo)
	redo_button.pressed.connect(redo)
	symmetry_button.toggled.connect(func(on: bool) -> void: canvas.symmetry = on)
	panel.part_selected.connect(func(id: String) -> void: canvas.place_id = id)
	panel.confirm_pressed.connect(confirm)
	panel.cancel_pressed.connect(cancel)
	canvas.changed.connect(_on_changed)

	look_box = VBoxContainer.new()
	look_box.name = "Look"
	look_box.position = Vector2(24, 720)
	panel.add_child(look_box)
	var title := Label.new()
	title.text = "Aussehen"
	look_box.add_child(title)
	var row := HBoxContainer.new()
	look_box.add_child(row)
	for c in COLORS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(40, 40)
		b.modulate = c
		b.pressed.connect(set_color.bind(c))
		row.add_child(b)
		color_buttons.append(b)
	pattern_option = OptionButton.new()
	for p in CellLook.PATTERNS:
		pattern_option.add_item(str(p).capitalize())
	look_box.add_child(pattern_option)
	stretch_slider = HSlider.new()
	stretch_slider.min_value = CellLook.MIN_STRETCH
	stretch_slider.max_value = CellLook.MAX_STRETCH
	stretch_slider.step = 0.05
	stretch_slider.value = 1.0
	stretch_slider.custom_minimum_size = Vector2(260, 32)
	look_box.add_child(stretch_slider)
	pattern_option.item_selected.connect(set_pattern_index)
	stretch_slider.value_changed.connect(set_stretch)


func open(build: CellBuild, unlocks: PartUnlocks, p_progress: CellProgress, stage: int) -> void:
	session = EditorSession.new(build, unlocks)
	progress = p_progress
	confirmed = false
	history.clear()
	panel.setup(session, progress, stage)
	canvas.setup(session, history)
	_update_buttons()


func _on_changed() -> void:
	panel.refresh()
	_update_buttons()


func _update_buttons() -> void:
	undo_button.disabled = not history.can_undo()
	redo_button.disabled = not history.can_redo()


func undo() -> void:
	var b := history.undo(session.working)
	if b != null:
		_show_build(b)


func redo() -> void:
	var b := history.redo(session.working)
	if b != null:
		_show_build(b)


func _show_build(b: CellBuild) -> void:
	session.working = b
	canvas.selected = -1
	canvas.queue_redraw()
	_on_changed()

## Verrechnet die DNA und meldet den neuen Aufbau; tut nichts, wenn es nicht geht.
func confirm() -> void:
	var b := session.confirm(progress)
	if b == null:
		return
	confirmed = true
	finished.emit(b)


func cancel() -> void:
	confirmed = false
	finished.emit(session.cancel())


## Der Editor arbeitet auf einer Kopie; main.gd übernimmt look nach dem Bestätigen.
func set_look(l: CellLook) -> void:
	look = l.copy()
	canvas.look = look
	pattern_option.select(CellLook.PATTERNS.find(look.pattern))
	stretch_slider.set_value_no_signal(look.stretch)
	canvas.queue_redraw()


func set_color(c: Color) -> void:
	if look == null:
		return
	look.color = c
	canvas.queue_redraw()


func set_pattern_index(i: int) -> void:
	if look == null:
		return
	look.set_pattern(CellLook.PATTERNS[i])
	canvas.queue_redraw()


func set_stretch(s: float) -> void:
	if look == null:
		return
	look.set_stretch(s)
	canvas.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed:
		if event.physical_keycode == KEY_Z:
			undo()
		elif event.physical_keycode == KEY_Y:
			redo()
