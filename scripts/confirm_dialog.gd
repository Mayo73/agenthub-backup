class_name ConfirmDialog
extends Control

signal confirmed
signal cancelled

var shade: ColorRect
var box: PanelContainer
var question_label: Label
var cancel_button: Button
var ok_button: Button


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.6)
	add_child(shade)

	box = PanelContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.add_theme_stylebox_override("panel", UiStyle.panel(UiStyle.CARD, 24))
	box.custom_minimum_size = Vector2(600, 0)
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	box.add_child(vbox)

	question_label = UiStyle.label("", UiStyle.SIZE_NORMAL)
	vbox.add_child(question_label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)

	cancel_button = UiStyle.button("Abbrechen")
	cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(cancel_button)

	ok_button = UiStyle.button("Ja", UiStyle.PASS)
	ok_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(ok_button)

	cancel_button.pressed.connect(func(): _on_cancel_pressed())
	ok_button.pressed.connect(func(): _on_ok_pressed())


func ask(question: String, ok_text: String = "Ja") -> void:
	question_label.text = question
	ok_button.text = ok_text
	visible = true


func _on_cancel_pressed() -> void:
	visible = false
	cancelled.emit()


func _on_ok_pressed() -> void:
	visible = false
	confirmed.emit()
