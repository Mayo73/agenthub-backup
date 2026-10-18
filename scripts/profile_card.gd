class_name ProfileCard
extends PanelContainer

var demo_tag: Label
var avatar: AvatarView
var name_label: Label
var art_label: Label
var level_label: Label
var bio_label: Label
var facts_label: Label

var profile: SparProfile = null


func _init():
	add_theme_stylebox_override("panel", UiStyle.panel(UiStyle.CARD, 24))

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)

	demo_tag = UiStyle.label("TESTPROFIL · fiktiv", UiStyle.SIZE_SMALL, UiStyle.DEMO)
	demo_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(demo_tag)

	avatar = AvatarView.new()
	avatar.set_diameter(220.0)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(avatar)

	name_label = UiStyle.label("", UiStyle.SIZE_TITLE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	art_label = UiStyle.label("")
	art_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_label.add_theme_color_override("font_color", UiStyle.ACCENT)
	vbox.add_child(art_label)

	level_label = UiStyle.label("")
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_color_override("font_color", UiStyle.MUTED)
	vbox.add_child(level_label)

	bio_label = UiStyle.label("", UiStyle.SIZE_NORMAL)
	vbox.add_child(bio_label)

	facts_label = UiStyle.label("", UiStyle.SIZE_SMALL, UiStyle.MUTED)
	vbox.add_child(facts_label)


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
