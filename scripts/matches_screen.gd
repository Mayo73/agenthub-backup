class_name MatchesScreen
extends Control
## Reiter "Matches": alle Matches der aktiven Testperson mit Avatar, Name, Sportart und
## letzter Nachricht. Beendete Matches bleiben sichtbar und sind abgeblendet.

signal open_chat(match_id: String)

const PREVIEW_LENGTH := 40

var state: AppState
## Match-ID -> Button der Zeile
var rows: Dictionary = {}
var list: VBoxContainer
var empty_icon: Label
var empty_label: Label
var title_label: Label
var new_section: VBoxContainer
var new_row: HBoxContainer
var new_buttons: Dictionary = {}


func _init(app_state: AppState) -> void:
	state = app_state
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", UiStyle.GAP)
	margin.add_theme_constant_override("margin_bottom", UiStyle.GAP)
	margin.add_theme_constant_override("margin_left", UiStyle.GAP)
	margin.add_theme_constant_override("margin_right", UiStyle.GAP)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiStyle.GAP)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(box)

	title_label = UiStyle.label("Deine Matches", UiStyle.SIZE_TITLE)
	box.add_child(title_label)

	var new_title := UiStyle.label("Neue Matches", UiStyle.SIZE_SMALL, UiStyle.MUTED)
	new_section = VBoxContainer.new()
	new_section.add_theme_constant_override("separation", UiStyle.GAP)
	new_section.add_child(new_title)
	box.add_child(new_section)

	var new_scroll := ScrollContainer.new()
	new_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	new_scroll.custom_minimum_size = Vector2(0, 150)
	new_section.add_child(new_scroll)

	new_row = HBoxContainer.new()
	new_row.add_theme_constant_override("separation", UiStyle.GAP)
	new_scroll.add_child(new_row)

	empty_icon = UiStyle.empty_icon("♥")
	box.add_child(empty_icon)

	empty_label = UiStyle.label(
		"Noch keine Matches. Bekunde unter \"Entdecken\" Interesse – ein Match entsteht, wenn es beide wollen.",
		UiStyle.SIZE_NORMAL, UiStyle.MUTED
	)
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(empty_label)

	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", UiStyle.GAP)
	box.add_child(list)

	refresh()


## Text einer Zeile: Name und Sportart der anderen Person, darunter der Stand des Matches.
static func row_text(app_state: AppState, m: Dictionary) -> String:
	var other := app_state.profile(app_state.book.other(m, app_state.active_id))
	var head := "%s · %s" % [other.name, other.art] if other != null else "?"
	if m.get("ended_by", "") != "":
		return head + "\nMatch beendet"
	var last := app_state.chat.last_message(m["id"])
	if last.is_empty():
		return head + "\nNoch keine Nachrichten"
	var text: String = last["text"]
	if text.length() > PREVIEW_LENGTH:
		text = text.substr(0, PREVIEW_LENGTH) + "…"
	var sender := "Du"
	if last["from"] != app_state.active_id:
		var p := app_state.profile(last["from"])
		sender = p.name if p != null else "?"
	return "%s\n%s: %s" % [head, sender, text]


func refresh() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.free()
	rows.clear()

	var matches: Array = state.my_matches()
	for m in matches:
		var id: String = m["id"]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiStyle.GAP)

		var avatar := AvatarView.new()
		avatar.set_diameter(88)
		avatar.set_profile(state.profile(state.book.other(m, state.active_id)))
		row.add_child(avatar)

		var button := UiStyle.row_button(row_text(state, m))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(open_chat.emit.bind(id))
		row.add_child(button)

		if m.get("ended_by", "") != "":
			row.modulate = Color(1, 1, 1, 0.6)
		list.add_child(row)
		rows[id] = button

	empty_icon.visible = matches.is_empty()
	empty_label.visible = matches.is_empty()

	# Neue Matches Sektion leeren
	for child in new_row.get_children():
		new_row.remove_child(child)
		child.free()
	new_buttons.clear()

	var new_matches: Array = []
	for m in matches:
		var id: String = m["id"]
		if m.get("ended_by", "") == "" and state.chat.last_message(id).is_empty():
			new_matches.append(m)

	for m in new_matches:
		var id: String = m["id"]
		var other := state.profile(state.book.other(m, state.active_id))

		var button := Button.new()
		button.flat = true
		button.custom_minimum_size = Vector2(112, 140)

		var vbox := VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var avatar := AvatarView.new()
		avatar.set_diameter(96)
		avatar.set_profile(other)
		avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(avatar)

		var name_label := UiStyle.label(other.name, UiStyle.SIZE_SMALL)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(name_label)

		button.add_child(vbox)
		button.pressed.connect(open_chat.emit.bind(id))
		new_row.add_child(button)
		new_buttons[id] = button

	new_section.visible = not new_buttons.is_empty()
