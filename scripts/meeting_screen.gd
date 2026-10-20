class_name MeetingScreen
extends Control
## Treffen draußen vorschlagen, zustimmen oder absagen. Beide müssen zustimmen, jede Änderung verlangt neue Zustimmung.

signal changed
signal back

var state: AppState
var match_id := ""

var back_button: Button
var title_label: Label
var hint_label: Label
var days_label: Label
var status_card: PanelContainer
var status_label: Label
var summary_label: Label
var place_view: PlaceView
var place_edit: LineEdit
var date_edit: LineEdit
var time_edit: LineEdit
var form_picker: OptionButton
var intensity_picker: OptionButton
var rules_edit: LineEdit
var error_label: Label
var propose_button: Button
var approve_button: Button
var cancel_button: Button


func _init(app_state: AppState, id: String) -> void:
	state = app_state
	match_id = id

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", UiStyle.GAP)
	margin.add_theme_constant_override("margin_top", UiStyle.GAP)
	margin.add_theme_constant_override("margin_right", UiStyle.GAP)
	margin.add_theme_constant_override("margin_bottom", UiStyle.GAP)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	back_button = UiStyle.round_button("‹", UiStyle.TEXT, 64)
	back_button.pressed.connect(func() -> void: back.emit())
	vbox.add_child(back_button)

	title_label = UiStyle.label("Treffen mit %s" % _other_name(), UiStyle.SIZE_TITLE)
	vbox.add_child(title_label)

	hint_label = UiStyle.label("Nur draußen, freiwillig und ohne Gym-Buchung. Ort als Text, keine Standortfreigabe.", UiStyle.SIZE_SMALL, UiStyle.MUTED)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint_label)

	days_label = UiStyle.label("", UiStyle.SIZE_SMALL, UiStyle.MUTED)
	days_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(days_label)

	status_card = PanelContainer.new()
	var panel_style := UiStyle.card_panel(UiStyle.CARD, UiStyle.RADIUS)
	status_card.add_theme_stylebox_override("panel", panel_style)
	vbox.add_child(status_card)

	var status_vbox := VBoxContainer.new()
	status_vbox.add_theme_constant_override("separation", 12)
	status_card.add_child(status_vbox)

	status_label = UiStyle.label("")
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_vbox.add_child(status_label)

	summary_label = UiStyle.label("", UiStyle.SIZE_NORMAL, UiStyle.ACCENT)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_vbox.add_child(summary_label)

	place_edit = _line_edit(vbox, "Ort draußen", "z. B. Stadtpark, Wiese am Teich")
	place_edit.text_changed.connect(func(new_text: String) -> void: place_view.set_place(new_text))

	place_view = PlaceView.new()
	place_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(place_view)
	date_edit = _line_edit(vbox, "Datum", "TT.MM.JJJJ")
	time_edit = _line_edit(vbox, "Uhrzeit", "HH:MM")
	form_picker = _picker(vbox, "Trainingsform", MeetingBook.FORMS)
	intensity_picker = _picker(vbox, "Intensität", MeetingBook.INTENSITIES)
	intensity_picker.select(MeetingBook.INTENSITIES.find("mittel"))
	rules_edit = _line_edit(vbox, "Gemeinsame Regeln", "z. B. kein Kopfkontakt, Tap = sofort Stopp")

	error_label = UiStyle.label("", UiStyle.SIZE_NORMAL, UiStyle.PASS)
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(error_label)

	propose_button = UiStyle.button("Vorschlagen", UiStyle.ACCENT)
	propose_button.pressed.connect(func() -> void: propose())
	vbox.add_child(propose_button)

	approve_button = UiStyle.button("Zustimmen", UiStyle.LIKE)
	approve_button.pressed.connect(_on_approve)
	vbox.add_child(approve_button)

	cancel_button = UiStyle.button("Absagen", UiStyle.PASS)
	cancel_button.pressed.connect(_on_cancel)
	vbox.add_child(cancel_button)

	load_meeting()
	refresh()


## Felder aus einem bestehenden Vorschlag füllen.
func load_meeting() -> void:
	var meeting: Dictionary = state.meetings.get_meeting(match_id)
	if meeting.is_empty():
		return
	place_edit.text = str(meeting.get("place", ""))
	date_edit.text = str(meeting.get("date", ""))
	time_edit.text = str(meeting.get("time", ""))
	var form_index: int = MeetingBook.FORMS.find(str(meeting.get("form", "")))
	if form_index >= 0:
		form_picker.select(form_index)
	var intensity_index: int = MeetingBook.INTENSITIES.find(str(meeting.get("intensity", "mittel")))
	if intensity_index >= 0:
		intensity_picker.select(intensity_index)
	rules_edit.text = str(meeting.get("rules", ""))
	place_view.set_place(place_edit.text)


## Angaben aus den Feldern.
func details() -> Dictionary:
	return {
		"place": place_edit.text,
		"date": date_edit.text,
		"time": time_edit.text,
		"form": form_picker.get_item_text(form_picker.selected) if form_picker.selected >= 0 else "",
		"intensity": intensity_picker.get_item_text(intensity_picker.selected) if intensity_picker.selected >= 0 else "mittel",
		"rules": rules_edit.text,
	}


func refresh() -> void:
	status_label.text = MeetingStatus.text(state, match_id)
	var m: Dictionary = state.book.get_match(match_id)
	days_label.text = ProfileFacts.common_days_text(state.active(), state.profile(state.book.other(m, state.active_id))) if not m.is_empty() else ""
	summary_label.text = MeetingStatus.summary(state.meetings.get_meeting(match_id))
	approve_button.visible = MeetingStatus.can_approve(state, match_id)
	cancel_button.visible = MeetingStatus.can_cancel(state, match_id)
	propose_button.disabled = not state.can_write(match_id)
	propose_button.text = "Änderung vorschlagen" if state.meetings.has_meeting(match_id) else "Vorschlagen"


## Vorschlag (oder Änderung) abschicken. Bei fehlenden Angaben erscheinen die Hinweise.
func propose() -> bool:
	var problems: Array[String] = state.propose_meeting(match_id, details())
	if not problems.is_empty():
		error_label.text = "\n".join(problems)
		return false
	error_label.text = ""
	refresh()
	changed.emit()
	return true


func _on_approve() -> void:
	state.approve_meeting(match_id)
	refresh()
	changed.emit()


func _on_cancel() -> void:
	state.cancel_meeting(match_id)
	refresh()
	changed.emit()


func _other_name() -> String:
	var m: Dictionary = state.book.get_match(match_id)
	if m.is_empty():
		return ""
	var other: SparProfile = state.profile(state.book.other(m, state.active_id))
	return other.name if other != null else ""


func _line_edit(parent: VBoxContainer, caption: String, placeholder: String) -> LineEdit:
	parent.add_child(UiStyle.label(caption))
	var edit := LineEdit.new()
	edit.placeholder_text = placeholder
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_input(edit)
	parent.add_child(edit)
	return edit


func _picker(parent: VBoxContainer, caption: String, items: Array[String]) -> OptionButton:
	parent.add_child(UiStyle.label(caption))
	var picker := OptionButton.new()
	for item in items:
		picker.add_item(item)
	UiStyle.style_option(picker)
	parent.add_child(picker)
	return picker
