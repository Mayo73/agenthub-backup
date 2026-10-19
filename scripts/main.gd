class_name Main
extends Control
## Startbildschirm der Hub Engine. Der grafische Editor entsteht schrittweise;
## bis dahin zeigt der Bildschirm Version und Engine-Kern.

const VERSION := "0.1.0"

var title_label: Label
var info_label: Label


func _ready() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	title_label = Label.new()
	title_label.text = "Hub Engine %s" % VERSION
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	info_label = Label.new()
	info_label.text = "Aufgebaut auf Godot %s · Editor folgt" % Engine.get_version_info()["string"]
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info_label)
