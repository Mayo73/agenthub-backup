class_name ChatScreen
extends Control
## Bildschirm für Demochat zwischen den beiden Testpersonen eines Matches.

signal changed
signal back
signal open_meeting(match_id: String)

var state: AppState
var match_id := ""

var back_button: Button
var avatar: AvatarView
var title_label: Label
var demo_hint: Label
var messages_box: VBoxContainer
var empty_icon: Label
var empty_label: Label
var closed_label: Label
var input: LineEdit
var send_button: Button
var end_button: Button
var block_button: Button
var dialog: ConfirmDialog
var meeting_button: Button
var meeting_label: Label

var pending := ""


func _init(app_state: AppState, id: String) -> void:
	state = app_state
	match_id = id

	set_anchors_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layout)

	# Kopf: HBoxContainer mit Zurück-Button, Avatar und Titel
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 100)
	header.add_theme_constant_override("separation", UiStyle.GAP)
	layout.add_child(header)

	back_button = UiStyle.round_button("‹", UiStyle.TEXT, 64)
	header.add_child(back_button)

	avatar = AvatarView.new()
	avatar.set_diameter(64.0)
	header.add_child(avatar)

	title_label = UiStyle.label("", UiStyle.SIZE_TITLE)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)

	# Demo-Hinweis
	demo_hint = UiStyle.label("Demochat: Nachrichten bleiben auf diesem Gerät, es wird nichts verschickt.", UiStyle.SIZE_SMALL)
	demo_hint.add_theme_color_override("font_color", UiStyle.DEMO)
	layout.add_child(demo_hint)

	# HBoxContainer mit end_button und block_button
	var action_hbox := HBoxContainer.new()
	action_hbox.custom_minimum_size = Vector2(0, 64)
	layout.add_child(action_hbox)

	end_button = UiStyle.button("Match beenden", UiStyle.PASS)
	end_button.custom_minimum_size = Vector2(0, 56)
	action_hbox.add_child(end_button)

	block_button = UiStyle.button("Blockieren", UiStyle.PASS)
	block_button.custom_minimum_size = Vector2(0, 56)
	action_hbox.add_child(block_button)

	meeting_button = UiStyle.button("Treffen", UiStyle.ACCENT)
	meeting_button.custom_minimum_size = Vector2(0, 56)
	action_hbox.add_child(meeting_button)

	# ScrollContainer mit messages_box
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)

	messages_box = VBoxContainer.new()
	messages_box.add_theme_constant_override("separation", 10)
	messages_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(messages_box)

	# Leerzustand mit Symbol (T-0475)
	empty_icon = UiStyle.empty_icon("💬")
	layout.add_child(empty_icon)
	empty_label = UiStyle.label("Noch keine Nachrichten. Schreib die erste!", UiStyle.SIZE_NORMAL, UiStyle.MUTED)
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(empty_label)

	# Geschlossen-Hinweis
	closed_label = UiStyle.label("Dieses Match ist beendet. Neue Nachrichten und Treffen sind nicht mehr möglich.", UiStyle.SIZE_NORMAL, UiStyle.PASS)
	layout.add_child(closed_label)

	meeting_label = UiStyle.label("Noch kein Treffvorschlag.", UiStyle.SIZE_NORMAL, UiStyle.MUTED)
	meeting_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(meeting_label)

	# Eingabe: HBoxContainer mit LineEdit und Button
	var input_hbox := HBoxContainer.new()
	input_hbox.custom_minimum_size = Vector2(0, 88)
	layout.add_child(input_hbox)

	input = LineEdit.new()
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.max_length = ChatLog.MAX_LENGTH
	input.placeholder_text = "Nachricht schreiben …"
	input_hbox.add_child(input)
	UiStyle.style_input(input)

	send_button = UiStyle.round_button("➤", UiStyle.ACCENT, 72)
	input_hbox.add_child(send_button)

	# ConfirmDialog als letztes Kind direkt am Bildschirm
	dialog = ConfirmDialog.new()
	add_child(dialog)

	# Signale verbinden
	back_button.pressed.connect(_on_back_pressed)
	send_button.pressed.connect(_on_send_pressed)
	input.text_submitted.connect(_on_text_submitted)
	end_button.pressed.connect(_on_end_pressed)
	block_button.pressed.connect(_on_block_pressed)
	meeting_button.pressed.connect(func() -> void: open_meeting.emit(match_id))
	dialog.confirmed.connect(_on_dialog_confirmed)
	dialog.cancelled.connect(_on_dialog_cancelled)

	refresh()


func other() -> SparProfile:
	var m := state.book.get_match(match_id)
	if not m.is_empty():
		var other_id := state.book.other(m, state.active_id)
		return state.profile(other_id)
	return null


func refresh() -> void:
	# Titel und Avatar aktualisieren
	var m := state.book.get_match(match_id)
	if not m.is_empty():
		var other_id := state.book.other(m, state.active_id)
		var other := state.profile(other_id)
		if other:
			avatar.set_profile(other)
			title_label.text = "%s · %s" % [other.name, other.art]

	# messages_box leeren und alte Labels entfernen
	for c in messages_box.get_children():
		messages_box.remove_child(c)
		c.free()

	# Nachrichten anzeigen als Sprechblasen
	var msgs := state.chat.messages_for(match_id)
	if msgs.is_empty():
		empty_icon.visible = true
		empty_label.visible = true
	else:
		empty_icon.visible = false
		empty_label.visible = false
		for msg in msgs:
			var label := UiStyle.bubble(msg["text"], msg["from"] == state.active_id)
			messages_box.add_child(label)

	# Writable prüfen und geschlossene Matches anzeigen
	var writable := state.can_write(match_id)
	end_button.disabled = not writable
	block_button.disabled = not writable
	send_button.disabled = not writable
	input.editable = writable

	if writable:
		closed_label.visible = false
	else:
		closed_label.visible = true
		var ended_by_id: String = "" if not m.has("ended_by") else m["ended_by"]
		if ended_by_id != "":
			if ended_by_id == state.active_id:
				closed_label.text = "Beendet von dir. Neue Nachrichten und Treffen sind nicht mehr möglich."
			else:
				var ended_by_name := state.profile(ended_by_id).name
				closed_label.text = "Beendet von %s. Neue Nachrichten und Treffen sind nicht mehr möglich." % ended_by_name

	meeting_label.text = MeetingStatus.text(state, match_id)


func send() -> bool:
	var result: bool = state.send_message(match_id, input.text)
	if result:
		input.text = ""
		refresh()
		changed.emit()
	return result


func _on_end_pressed() -> void:
	pending = "beenden"
	dialog.ask("Match mit %s beenden? Danach sind keine Nachrichten und Treffen mehr möglich." % other().name, "Beenden")


func _on_block_pressed() -> void:
	pending = "blockieren"
	dialog.ask("%s blockieren? Ihr seht euch danach nicht mehr unter „Entdecken“." % other().name, "Blockieren")


func _on_dialog_confirmed() -> void:
	match pending:
		"beenden":
			state.end_match(match_id)
		"blockieren":
			state.block(other().id)
		_:
			pass

	pending = ""
	refresh()
	changed.emit()


func _on_dialog_cancelled() -> void:
	pending = ""


func _on_back_pressed() -> void:
	back.emit()


func _on_send_pressed() -> void:
	send()


func _on_text_submitted(new_text: String) -> void:
	send()
