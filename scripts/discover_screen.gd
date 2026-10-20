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

# Filter-OptionButtons
var art_filter: OptionButton
var level_filter: OptionButton


func _init(app_state: AppState) -> void:
	state = app_state

	set_anchors_preset(Control.PRESET_FULL_RECT)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, UiStyle.GAP)
	add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", UiStyle.GAP)
	margin.add_child(vbox)

	# Filterleiste als erstes Kind der VBoxContainer
	var filter_hbox := HBoxContainer.new()
	filter_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	filter_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(filter_hbox)

	art_filter = OptionButton.new()
	art_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_option(art_filter)
	art_filter.item_selected.connect(func(index: int) -> void: set_filter(art_filter.get_selected_id(), level_filter.get_selected_id()))
	filter_hbox.add_child(art_filter)

	level_filter = OptionButton.new()
	level_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiStyle.style_option(level_filter)
	level_filter.item_selected.connect(func(index: int) -> void: set_filter(art_filter.get_selected_id(), level_filter.get_selected_id()))
	filter_hbox.add_child(level_filter)

	# Auswahl beim Aufbau aus state.filter übernehmen
	_initialize_filters()

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

	# Runde Aktionsknöpfe unter der Karte mit kleiner Beschriftung: Nein links, Ja rechts
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 72)
	vbox.add_child(hbox)

	pass_button = UiStyle.round_button("✕", UiStyle.PASS)
	pass_button.tooltip_text = "Überspringen"
	pass_button.pressed.connect(decide_pass)
	hbox.add_child(UiStyle.labeled(pass_button, "Überspringen"))

	like_button = UiStyle.round_button("♥", UiStyle.LIKE)
	like_button.tooltip_text = "Interesse"
	like_button.pressed.connect(decide_like)
	hbox.add_child(UiStyle.labeled(like_button, "Interesse"))

	refresh()


func _initialize_filters() -> void:
	# Sportarten einfügen
	art_filter.add_item("Alle Sportarten")
	for art in DemoData.ARTS:
		art_filter.add_item(art)

	# Erfahrung einfügen
	level_filter.add_item("Jede Erfahrung")
	for level_name in SparProfile.LEVELS:
		level_filter.add_item(level_name)

	# Auswahl aus state.filter übernehmen
	var art_index := 0
	if not state.filter.art.is_empty():
		art_index = DemoData.ARTS.find(state.filter.art) + 1
	art_filter.select(art_index)

	var level_index := 0
	if state.filter.level != -1:
		level_index = state.filter.level + 1
	level_filter.select(level_index)


func set_filter(art_index: int, level_index: int) -> void:
	# state.filter.art = "" bei Index 0, sonst DemoData.ARTS[art_index - 1]
	if art_index == 0:
		state.filter.art = ""
	else:
		state.filter.art = DemoData.ARTS[art_index - 1]

	# state.filter.level = level_index - 1
	state.filter.level = level_index - 1

	# beide OptionButton entsprechend select(...)
	art_filter.select(art_index)
	level_filter.select(level_index)

	# match_label unsichtbar
	match_label.visible = false

	# changed.emit() und refresh()
	changed.emit()
	refresh()


func refresh() -> void:
	var profile := current()

	if profile == null:
		card.visible = false
		pass_button.disabled = true
		like_button.disabled = true
		match_label.visible = false

		# Leerzustandstext prüfen
		if state.filter.is_active():
			empty_label.text = "Keine Testprofile für „%s“. Ändere den Filter." % state.filter.describe()
		else:
			empty_label.text = "Keine weiteren Testprofile. Wechsle die Testperson oder setze die Demo im Profil zurück."
		empty_label.visible = true
	else:
		card.visible = true
		empty_label.visible = false
		pass_button.disabled = false
		like_button.disabled = false
		card.set_profile(profile)


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
		card.show_stamp(gesture.stamp_kind(), gesture.stamp_strength())
		# Visuelle Rückmeldung während des Wischens
		card.position.x = gesture.offset.x
		card.rotation = gesture.tilt()


func _reset_card_position() -> void:
	card.position.x = 0.0
	card.rotation = 0.0
	card.show_stamp(SwipeGesture.Result.NONE, 0.0)


func current() -> SparProfile:
	var candidates := state.candidates()
	if not candidates.is_empty():
		return candidates[0]
	return null


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
	var profile := current()
	if profile == null:
		return

	state.pass_on(profile.id)
	_reset_card_position()
	match_label.visible = false
	changed.emit()
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
