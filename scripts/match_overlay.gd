class_name MatchOverlay
extends Control
## Eigener „Match!“-Bildschirm über der App: großer Titel, beide Porträts nebeneinander,
## Knöpfe „Nachricht schreiben“ und „Weiter entdecken“.

signal write_requested(match_id: String)
signal closed

var match_id := ""
var title_label: Label
var text_label: Label
var me_avatar: AvatarView
var other_avatar: AvatarView
var write_button: Button
var continue_button: Button


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(UiStyle.BG, 0.94)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiStyle.GAP * 2)
	box.custom_minimum_size = Vector2(420, 0)
	center.add_child(box)

	title_label = UiStyle.label("Match!", UiStyle.SIZE_HERO, UiStyle.ACCENT_2)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title_label)

	var avatars := HBoxContainer.new()
	avatars.add_theme_constant_override("separation", UiStyle.GAP)
	avatars.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(avatars)

	me_avatar = AvatarView.new()
	me_avatar.set_diameter(200.0)
	avatars.add_child(me_avatar)

	other_avatar = AvatarView.new()
	other_avatar.set_diameter(200.0)
	avatars.add_child(other_avatar)

	text_label = UiStyle.label("")
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(text_label)

	write_button = UiStyle.button("Nachricht schreiben", UiStyle.ACCENT)
	write_button.pressed.connect(_on_write_pressed)
	box.add_child(write_button)

	continue_button = UiStyle.button("Weiter entdecken")
	continue_button.pressed.connect(_on_continue_pressed)
	box.add_child(continue_button)

	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func show_match(me: SparProfile, other: SparProfile, p_match_id: String) -> void:
	match_id = p_match_id
	me_avatar.set_profile(me)
	other_avatar.set_profile(other)
	text_label.text = "Du und %s wollt zusammen trainieren." % other.name
	visible = true


func _on_write_pressed() -> void:
	visible = false
	write_requested.emit(match_id)


func _on_continue_pressed() -> void:
	visible = false
	closed.emit()
