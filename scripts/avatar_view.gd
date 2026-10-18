class_name AvatarView
extends Control

## Zeigt den Avatar eines SparProfile als selbst gezeichneten Kreis mit Initialen an.
## Keine externen Bilddateien, alles wird per Code gezeichnet.

var profile: SparProfile = null
var diameter := 160.0:
	set(value):
		diameter = value
		custom_minimum_size = Vector2(diameter, diameter)

func _init():
	diameter = 160.0
	custom_minimum_size = Vector2(diameter, diameter)


func set_diameter(d: float) -> void:
	diameter = d
	custom_minimum_size = Vector2(diameter, diameter)


func set_profile(p: SparProfile) -> void:
	profile = p
	queue_redraw()


func shown_initials() -> String:
	if profile != null:
		return profile.initials()
	return "?"


func ring_color() -> Color:
	if profile != null:
		return profile.color.lightened(0.3)
	return UiStyle.MUTED


func _draw() -> void:
	var radius := diameter / 2.0
	var center := Vector2(diameter, diameter) * 0.5

	## Hintergrundkreis
	draw_circle(center, radius, UiStyle.CARD)

	## Ring
	draw_arc(center, radius, 0.0, TAU, 48, ring_color(), 4.0)

	## Initialen
	var initials := shown_initials()
	var font_size := int(diameter * 0.38)
	var font := ThemeDB.fallback_font
	var draw_pos := Vector2(center.x - diameter * 0.5, center.y - center.y)
	draw_string(font, draw_pos, initials, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, UiStyle.TEXT)
