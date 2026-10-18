extends Control
class_name DiscoverScreen

signal changed
signal matched(match_id: String)

var state: AppState
var gesture := SwipeGesture.new()

var card: ProfileCard
var empty_label: Label
var match_label: Label
var pass_button: Button
var like_button: Button


func _init(app_state: AppState) -> void:
	state = app_state

	set_anchors_preset(Control.PRESET_FULL_RECT)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	# Karte, die vertikal wächst
	card = ProfileCard.new()
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(card)

	# Leerschreiben-Label (zentriert)
	empty_label = UiStyle.label("Keine weiteren Testprofile. Wechsle die Testperson oder setze die Demo im Profil zurück.")
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(empty_label)

	# Match-Label (zunächst unsichtbar, Farbe UiStyle.LIKE)
	match_label = UiStyle.label("", UiStyle.SIZE_TITLE, UiStyle.LIKE)
	match_label.visible = false
	match_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(match_label)

	# HBoxContainer mit Knöpfen
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_child(hbox)

	pass_button = UiStyle.button("✕ Überspringen", UiStyle.PASS)
	pass_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pass_button.pressed.connect(decide_pass)
	hbox.add_child(pass_button)

	like_button = UiStyle.button("♥ Interesse",UiStyle.LIKE)
	like_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	like_button.pressed.connect(decide_like)
	hbox.add_child(like_button)

	refresh()


func _on_card_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			gesture.begin(event.position)
		else:
			var result := gesture.finish()
			match result:
				SwipeGesture.Result.LIKE:
					decide_like()
				SwipeGesture.Result.PASS:
					decide_pass()
				_:
					pass
			_reset_card_position()
	elif event is InputEventScreenDrag:
		gesture.move(event.position)
		# Visuelle Rückmeldung während des Wischens
		card.position.x = gesture.offset.x
		card.rotation = gesture.tilt()


func _reset_card_position() -> void:
	card.position.x = 0.0
	card.rotation = 0.0


func current() -> SparProfile:
	var candidates := state.candidates()
	if not candidates.is_empty():
		return candidates[0]
	return null


func refresh() -> void:
	var profile := current()

	if profile == null:
		card.visible = false
		empty_label.visible = true
		match_label.visible = false
		pass_button.disabled = true
		like_button.disabled = true
	else:
		card.visible = true
		empty_label.visible = false
		pass_button.disabled = false
		like_button.disabled = false
		card.set_profile(profile)


func decide_like() -> void:
	var profile := current()
	if profile == null:
		return

	var id := state.like(profile.id)

	_reset_card_position()

	if not id.is_empty():
		match_label.text = "Match mit %s! Ihr könnt jetzt schreiben." % profile.name
		match_label.visible = true
		matched.emit(id)
	else:
		match_label.visible = false

	changed.emit()
	refresh()


func decide_pass() -> void:
	print("[DEBUG] decide_pass called")
	var profile := current()
	if profile == null:
		print("[DEBUG] decide_pass: profile is null, returning")
		return

	state.pass_on(profile.id)
	_reset_card_position()
	match_label.visible = false
	print("[DEBUG] Emitting changed signal in decide_pass")
	changed.emit()
	print("[DEBUG] Refreshing...")
	refresh()


func swipe(from_pos: Vector2, to_pos: Vector2) -> void:
	gesture.begin(from_pos)
	gesture.move(to_pos)
	var result := gesture.finish()

	match result:
		SwipeGesture.Result.LIKE:
			decide_like()
		SwipeGesture.Result.PASS:
			decide_pass()
		_:
			pass
