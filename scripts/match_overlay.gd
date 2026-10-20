class_name MatchOverlay
extends Control

signal write_requested(match_id: String)
signal closed

var match_id := ""
var title_label: Label
var text_label: Label
var me_avatar: AvatarView
var other_avatar: AvatarView
var write_button: Button
var continue_button: Button

var vbox_container: VBoxContainer


func _init() -> void:
	# Hintergrund über die ganze Fläche
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = UiStyle.BG.lightened(0.25)
	add_child(bg)

	# VBoxContainer für vertikale Ausrichtung mit GAP Abstand
	vbox_container = VBoxContainer.new()
	vbox_container.add_theme_constant_override("separation", UiStyle.GAP)
	add_child(vbox_container)

	# Titel "Match!"
	title_label = UiStyle.label("Match!", UiStyle.SIZE_HERO, UiStyle.ACCENT_2)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_container.add_child(title_label)

	# Avatare nebeneinander in HBoxContainer
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", UiStyle.GAP)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox_container.add_child(hbox)

	# Meine Avatar-Ansicht
	me_avatar = AvatarView.new()
	me_avatar.set_diameter(200.0)
	hbox.add_child(me_avatar)

	# Avatar der anderen Person
	other_avatar = AvatarView.new()
	other_avatar.set_diameter(200.0)
	hbox.add_child(other_avatar)

	# Beschreibungstext
	text_label = UiStyle.label("")
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_container.add_child(text_label)

	# Buttons nebeneinander
	var button_hbox := HBoxContainer.new()
	button_hbox.add_theme_constant_override("separation", UiStyle.GAP)
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox_container.add_child(button_hbox)

	# "Nachricht schreiben"-Button (anfangs versteckt)
	write_button = UiStyle.button("Nachricht schreiben", UiStyle.ACCENT)
	write_button.visible = false
	write_button.pressed.connect(_on_write_pressed)
	button_hbox.add_child(write_button)

	# "Weiter entdecken"-Button (anfangs versteckt)
	continue_button = UiStyle.button("Weiter entdecken")
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	button_hbox.add_child(continue_button)

	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func show_match(me: SparProfile, other: SparProfile, p_match_id: String) -> void:
	match_id = p_match_id
	me_avatar.set_profile(me)
	other_avatar.set_profile(other)
	text_label.text = "Du und %s wollt zusammen trainieren." % other.name
	write_button.visible = false
	continue_button.visible = false
	visible = true


func _on_write_pressed() -> void:
	write_button.visible = false
	write_requested.emit(match_id)


func _on_continue_pressed() -> void:
	continue_button.visible = false
	closed.emit()
