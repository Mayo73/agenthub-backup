class_name PerspectiveBar
extends PanelContainer
## Demo-Leiste oben in der App: zeigt, aus wessen Sicht die App bedient wird, und wechselt
## die Testperson. Immer als Demofunktion gekennzeichnet (Farbe UiStyle.DEMO).

signal switched(id: String)

var tag_label: Label
var avatar: AvatarView
var picker: OptionButton


func _init() -> void:
	add_theme_stylebox_override("panel", UiStyle.panel(UiStyle.CARD, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)

	tag_label = UiStyle.label("DEMO-PERSPEKTIVE", UiStyle.SIZE_SMALL, UiStyle.DEMO)
	tag_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	tag_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(tag_label)

	avatar = AvatarView.new()
	avatar.set_diameter(56)
	row.add_child(avatar)

	picker = OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.custom_minimum_size = Vector2(0, UiStyle.BUTTON_HEIGHT)
	picker.add_theme_font_size_override("font_size", UiStyle.SIZE_NORMAL)
	picker.get_popup().add_theme_font_size_override("font_size", UiStyle.SIZE_NORMAL)
	picker.item_selected.connect(_on_item_selected)
	row.add_child(picker)


## Füllt die Auswahl mit allen Testpersonen und markiert die aktive.
func set_state(state: AppState) -> void:
	picker.clear()
	for p in state.profiles:
		picker.add_item("Du bist: %s (%s)" % [p.name, p.art])
		var index := picker.item_count - 1
		picker.set_item_metadata(index, p.id)
		if p.id == state.active_id:
			picker.select(index)
	avatar.set_profile(state.active())


func _on_item_selected(index: int) -> void:
	switched.emit(String(picker.get_item_metadata(index)))
