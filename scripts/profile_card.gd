class_name ProfileCard
extends PanelContainer
## Bildschirmfüllende Profilkarte: großes Porträt mit abgerundeten Ecken, unten ein dunkler
## Verlauf mit Name und Alter, Chips für Kampfsportart und Niveau, Kurzbeschreibung und Merkmalen.
## Oben links der Hinweis, dass es ein fiktives Testprofil ist.

var demo_tag: Label
var avatar: AvatarView
var name_label: Label
var art_chip: PanelContainer
var art_label: Label
var level_chip: PanelContainer
var level_label: Label
var bio_label: Label
var facts_label: Label
## Stempel beim Wischen, über Porträt und Text.
var stamp_layer: Control
var like_stamp: PanelContainer
var pass_stamp: PanelContainer

var profile: SparProfile = null


func _init():
	var style := UiStyle.card_panel(UiStyle.CARD)
	style.set_content_margin_all(0)
	add_theme_stylebox_override("panel", style)

	avatar = AvatarView.new()
	avatar.set_fill(true)
	avatar.shade = true
	add_child(avatar)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	var tag_box := PanelContainer.new()
	var tag_style := UiStyle.panel(Color(0, 0, 0, 0.45), 999)
	tag_style.content_margin_left = 14
	tag_style.content_margin_right = 14
	tag_style.content_margin_top = 4
	tag_style.content_margin_bottom = 4
	tag_box.add_theme_stylebox_override("panel", tag_style)
	tag_box.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	demo_tag = UiStyle.label("TESTPROFIL · fiktiv", UiStyle.SIZE_SMALL, UiStyle.DEMO)
	demo_tag.autowrap_mode = TextServer.AUTOWRAP_OFF
	tag_box.add_child(demo_tag)
	vbox.add_child(tag_box)

	# schiebt den Text an den unteren Rand der Karte
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(spacer)

	name_label = UiStyle.overlay_label("", UiStyle.SIZE_HERO)
	vbox.add_child(name_label)

	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 10)
	chips.add_theme_constant_override("v_separation", 8)
	vbox.add_child(chips)
	art_chip = UiStyle.chip("", UiStyle.ACCENT)
	art_label = art_chip.get_child(0) as Label
	chips.add_child(art_chip)
	level_chip = UiStyle.chip("", UiStyle.ACCENT_2)
	level_label = level_chip.get_child(0) as Label
	chips.add_child(level_chip)

	bio_label = UiStyle.overlay_label("", UiStyle.SIZE_NORMAL)
	vbox.add_child(bio_label)

	facts_label = UiStyle.label("", UiStyle.SIZE_SMALL, UiStyle.TEXT.darkened(0.15))
	vbox.add_child(facts_label)

	stamp_layer = Control.new()
	stamp_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stamp_layer)
	like_stamp = UiStyle.stamp("SPARRING", UiStyle.LIKE)
	like_stamp.rotation = -0.3
	like_stamp.position = Vector2(40, 120)
	like_stamp.visible = false
	stamp_layer.add_child(like_stamp)
	pass_stamp = UiStyle.stamp("NEIN", UiStyle.PASS)
	pass_stamp.rotation = 0.3
	pass_stamp.position = Vector2(360, 100)
	pass_stamp.visible = false
	stamp_layer.add_child(pass_stamp)


func set_profile(p: SparProfile) -> void:
	profile = p

	if profile == null:
		return

	name_label.text = "%s, %d" % [p.name, p.age]
	art_label.text = p.art

	var years_text := "Jahre Training"
	if p.years == 1:
		years_text = "Jahr Training"
	level_label.text = "%s · %d %s" % [p.level_name(), p.years, years_text]

	bio_label.text = p.bio
	facts_label.text = ProfileFacts.all_text(p)
	avatar.set_profile(p)


## Zeigt beim Wischen den passenden Stempel, umso deutlicher, je größer `strength` ist.
func show_stamp(kind: int, strength: float) -> void:
	var on := strength > 0.0
	like_stamp.visible = on and kind == SwipeGesture.Result.LIKE
	pass_stamp.visible = on and kind == SwipeGesture.Result.PASS
	like_stamp.modulate.a = strength
	pass_stamp.modulate.a = strength
