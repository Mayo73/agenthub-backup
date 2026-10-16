class_name CellEditorPanel
extends CanvasLayer
## Bedienleiste des Zelleditors: Teile-Auswahl, DNA, Kosten, Fähigkeitsvorschau, Bestätigen und Abbrechen.

signal part_selected(id: String)
signal confirm_pressed
signal cancel_pressed

var session: EditorSession
var progress: CellProgress
var stage := 0
var selected_id := ""
var palette: VBoxContainer
var info: VBoxContainer
## Teil-ID -> Button
var part_buttons := {}
var dna_label: Label
var cost_label: Label
var preview_label: Label
var confirm_button: Button
var cancel_button: Button


func _init() -> void:
	layer = 5
	palette = VBoxContainer.new()
	palette.name = "Palette"
	palette.position = Vector2(24, 24)
	add_child(palette)
	info = VBoxContainer.new()
	info.name = "Info"
	info.position = Vector2(1520, 24)
	info.add_theme_constant_override("separation", 10)
	add_child(info)
	dna_label = _label()
	cost_label = _label()
	preview_label = _label()
	confirm_button = Button.new()
	confirm_button.text = "Bestätigen"
	confirm_button.custom_minimum_size = Vector2(360, 52)
	info.add_child(confirm_button)
	cancel_button = Button.new()
	cancel_button.text = "Abbrechen"
	cancel_button.custom_minimum_size = Vector2(360, 52)
	info.add_child(cancel_button)
	confirm_button.pressed.connect(func() -> void: confirm_pressed.emit())
	cancel_button.pressed.connect(func() -> void: cancel_pressed.emit())


func _label() -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 22)
	info.add_child(l)
	return l


## Baut die Teile-Knöpfe für alle freigeschalteten Teile und zeigt die Werte.
func setup(p_session: EditorSession, p_progress: CellProgress, p_stage: int) -> void:
	session = p_session
	progress = p_progress
	stage = p_stage
	selected_id = ""
	for child in palette.get_children():
		palette.remove_child(child)
		child.queue_free()
	part_buttons.clear()
	for id in PartCatalog.ids():
		if session.unlocks.is_unlocked(id):
			var b := Button.new()
			b.text = "%s (%d)" % [PartCatalog.name_of(id), PartCatalog.cost_of(id)]
			b.toggle_mode = true
			b.custom_minimum_size = Vector2(260, 44)
			b.pressed.connect(select.bind(id))
			palette.add_child(b)
			part_buttons[id] = b
	refresh()


## Wählt das Teil, das beim nächsten Klick in die Zelle eingebaut wird.
func select(id: String) -> void:
	selected_id = id
	for key in part_buttons:
		var b: Button = part_buttons[key]
		b.set_pressed_no_signal(key == id)
	part_selected.emit(id)


## Aktualisiert DNA, Kosten, Vorschau und ob Bestätigen möglich ist.
func refresh() -> void:
	dna_label.text = "DNA: %d" % progress.dna
	var c := session.cost()
	if c >= 0:
		cost_label.text = "Kosten: %d DNA" % c
	else:
		cost_label.text = "Rückerstattung: %d DNA" % -c
	preview_label.text = "\n".join(PackedStringArray(EditorPreview.lines(session.original, session.working, stage)))
	confirm_button.disabled = not session.can_confirm(progress.dna)
