class_name ProfileScreen
extends Control

signal changed
signal reset_requested


var state: AppState
var avatar: AvatarView
var demo_hint: Label
var name_edit: LineEdit
var art_picker: OptionButton
var level_picker: OptionButton
var age_spin: SpinBox
var years_spin: SpinBox
var bio_edit: LineEdit
var error_label: Label
var save_button: Button
var reset_button: Button
var dialog: ConfirmDialog


func _init(app_state: AppState) -> void:
	state = app_state

	# ScrollContainer mit PRESET_FULL_RECT
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	# VBoxContainer mit SIZE_EXPAND_FILL in der Breite
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# AvatarView (Durchmesser 160, SIZE_SHRINK_CENTER)
	avatar = AvatarView.new()
	avatar.diameter = 160.0
	avatar.custom_minimum_size = Vector2(160, 160)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(avatar)

	# Demo-Hinweis (Text, UiStyle.SIZE_SMALL, Farbe UiStyle.DEMO)
	demo_hint = UiStyle.label("Du bearbeitest das Demoprofil der aktiven Testperson.", UiStyle.SIZE_SMALL, UiStyle.DEMO)
	vbox.add_child(demo_hint)

	# Name-Label und Eingabe
	vbox.add_child(UiStyle.label("Name"))
	name_edit = LineEdit.new()
	name_edit.max_length = ProfileForm.NAME_MAX
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(name_edit)

	# Kampfsportart-Label und Picker
	vbox.add_child(UiStyle.label("Kampfsportart"))
	art_picker = OptionButton.new()
	for art in DemoData.ARTS:
		art_picker.add_item(art)
	vbox.add_child(art_picker)

	# Erfahrung-Label und Picker
	vbox.add_child(UiStyle.label("Erfahrung"))
	level_picker = OptionButton.new()
	for level in SparProfile.LEVELS:
		level_picker.add_item(level)
	vbox.add_child(level_picker)

	# Alter-Label und SpinBox
	vbox.add_child(UiStyle.label("Alter"))
	age_spin = SpinBox.new()
	age_spin.min_value = 18
	age_spin.max_value = 99
	age_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(age_spin)

	# Trainingsjahre-Label und SpinBox
	vbox.add_child(UiStyle.label("Trainingsjahre"))
	years_spin = SpinBox.new()
	years_spin.min_value = 0
	years_spin.max_value = 60
	years_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(years_spin)

	# Über-mich-Label und Eingabe
	vbox.add_child(UiStyle.label("Über mich"))
	bio_edit = LineEdit.new()
	bio_edit.max_length = ProfileForm.BIO_MAX
	bio_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(bio_edit)

	# Error-Label (Farbe UiStyle.PASS, zunächst leer)
	error_label = UiStyle.label("", UiStyle.SIZE_NORMAL, UiStyle.PASS)
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(error_label)

	# Save-Button
	save_button = UiStyle.button("Profil speichern", UiStyle.ACCENT)
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(save_button)

	# Reset-Button
	reset_button = UiStyle.button("Demo zurücksetzen", UiStyle.PASS)
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(reset_button)

	# ConfirmDialog als letztes Kind direkt am Bildschirm (nicht im Scroll-Bereich)
	dialog = ConfirmDialog.new()
	add_child(dialog)

	# Signal-Verbindungen
	save_button.pressed.connect(_on_save_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	dialog.confirmed.connect(_on_dialog_confirmed)

	# Profil laden
	load_profile()


func _on_save_pressed() -> void:
	save_profile()


func _on_reset_pressed() -> void:
	dialog.ask("Alle Profile, Matches, Nachrichten und Treffen auf die ursprünglichen Testdaten zurücksetzen?", "Zurücksetzen")


func _on_dialog_confirmed() -> void:
	reset_requested.emit()


func load_profile() -> void:
	var p := state.active()
	if p == null:
		return

	name_edit.text = p.name
	# Finde den Index für die Kampfsportart
	for i in range(art_picker.get_item_count()):
		if art_picker.get_item_text(i) == p.art:
			art_picker.selected = i
			break
	level_picker.selected = p.level
	age_spin.value = float(p.age)
	years_spin.value = float(p.years)
	bio_edit.text = p.bio
	avatar.set_profile(p)
	error_label.text = ""


func form_values() -> Dictionary:
	return {
		"name": name_edit.text,
		"art": art_picker.get_item_text(art_picker.selected),
		"level": level_picker.selected,
		"age": int(age_spin.value),
		"years": int(years_spin.value),
		"bio": bio_edit.text
	}


func save_profile() -> bool:
	var p := ProfileForm.applied(state.active(), form_values())

	if p == null:
		error_label.text = "\n".join(ProfileForm.errors(form_values()))
		return false

	state.update_profile(p)
	error_label.text = "Gespeichert."
	error_label.add_theme_color_override("font_color", UiStyle.LIKE)
	avatar.set_profile(state.active())
	changed.emit()
	return true
