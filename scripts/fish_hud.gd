class_name FishHud
extends CanvasLayer
## Anzeige der Fischphase: Tiefe, DNA, Wachstum, Steuerungshilfe und kurze Meldungen.

const HELP := "W / linke Maustaste: schwimmen · A/D: drehen · Leertaste: auftauchen · Umschalt: abtauchen · E: Entwicklung"
const UPGRADE_HINT := "E: Verbesserung möglich"
const FLASH_TIME := 0.4
const BITE_MESSAGE := "Ein Raubfisch hat dich gebissen!"
## Färbt nur den Bildrand: Die Mitte bleibt frei, damit Fisch und Umgebung sichtbar bleiben.
const VIGNETTE_SHADER := """
shader_type canvas_item;
void fragment() {
	vec2 d = abs(UV - vec2(0.5)) * 2.0;
	float edge = smoothstep(0.55, 1.0, max(d.x, d.y));
	COLOR = vec4(COLOR.rgb, clamp(COLOR.a * edge * 2.4, 0.0, 1.0));
}
"""

var depth_label: Label
var dna_label: Label
var growth_label: Label
var health_label: Label
var warning_label: Label
var upgrade_label: Label
var size_label: Label
var help_label: Label
var message_label: Label
var message_left := 0.0
## Wichtigere Meldungen (z. B. ein Biss) werden nicht von gewöhnlichen überschrieben.
var message_priority := 0
var flash_rect: ColorRect
var flash_left := 0.0


func _init() -> void:
	layer = 5
	flash_rect = ColorRect.new()
	flash_rect.name = "Flash"
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(0.85, 0.1, 0.1, 0.0)
	var shader := Shader.new()
	shader.code = VIGNETTE_SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	flash_rect.material = material
	add_child(flash_rect)
	depth_label = make_label("Depth", Vector2(40, 30), 32)
	dna_label = make_label("Dna", Vector2(40, 76), 28)
	growth_label = make_label("Growth", Vector2(40, 116), 28)
	health_label = make_label("Health", Vector2(40, 156), 28)
	show_health(1.0)
	upgrade_label = make_label("UpgradeHint", Vector2(40, 196), 26)
	upgrade_label.text = UPGRADE_HINT
	upgrade_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
	upgrade_label.visible = false
	size_label = make_label("Size", Vector2(320, 116), 28)
	help_label = make_label("Help", Vector2(40, 1010), 22)
	help_label.text = HELP
	## Dunkle Unterlage, damit die Hilfe auch auf hellem Sand lesbar bleibt
	var backing := StyleBoxFlat.new()
	backing.bg_color = Color(0.0, 0.03, 0.06, 0.55)
	backing.set_content_margin_all(8)
	backing.set_corner_radius_all(6)
	help_label.add_theme_stylebox_override("normal", backing)
	warning_label = make_label("Warning", Vector2(560, 200), 30)
	warning_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.15))
	warning_label.visible = false
	message_label = make_label("Message", Vector2(560, 140), 30)
	message_label.visible = false
	show_depth(FishWorld.depth_of(FishWorld.START))
	show_progress(FishProgress.new())


func make_label(label_name: String, pos: Vector2, font_size: int) -> Label:
	var l := Label.new()
	l.name = label_name
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	add_child(l)
	return l


static func depth_text(depth: float) -> String:
	return "Tiefe: %d m" % roundi(depth)


static func growth_text(progress: FishProgress) -> String:
	if progress.is_final_stage():
		return "Wachstum: ausgewachsen"
	return "Wachstum: %d / %d" % [progress.growth, FishProgress.GROWTH_NEEDED[progress.stage]]


static func size_text(progress: FishProgress) -> String:
	return "Größe: %d / %d" % [progress.stage + 1, FishProgress.SIZES.size()]


func show_depth(depth: float) -> void:
	depth_label.text = depth_text(depth)


func show_progress(progress: FishProgress) -> void:
	dna_label.text = "DNA: %d" % progress.dna
	growth_label.text = growth_text(progress)
	size_label.text = size_text(progress)


func show_message(text: String, seconds: float = 4.0, priority: int = 0) -> void:
	if message_left > 0.0 and priority < message_priority:
		return
	message_label.text = text
	message_label.visible = true
	message_left = seconds
	message_priority = priority


## Blendet die aktuelle Meldung sofort aus (z. B. beim Öffnen eines Menüs).
func clear_message() -> void:
	message_left = 0.0
	message_priority = 0
	message_label.visible = false


static func health_text(ratio: float) -> String:
	return "Gesundheit: %d %%" % roundi(clampf(ratio, 0.0, 1.0) * 100.0)


func show_health(ratio: float) -> void:
	health_label.text = health_text(ratio)


## Lässt den Bildrand kurz rot aufleuchten und meldet den Biss vorrangig.
func flash() -> void:
	flash_left = FLASH_TIME
	flash_rect.color.a = 0.35
	show_message(BITE_MESSAGE, 2.0, 1)


## Zeigt die Warnung vor Raubfischen; ein leerer Text blendet sie aus.
func show_warning(text: String) -> void:
	warning_label.text = text
	warning_label.visible = text != ""


func tick(delta: float) -> void:
	if flash_left > 0.0:
		flash_left = maxf(0.0, flash_left - delta)
		flash_rect.color.a = 0.35 * flash_left / FLASH_TIME
	if message_left <= 0.0:
		return
	message_left -= delta
	if message_left <= 0.0:
		message_label.visible = false
		message_priority = 0


func _process(delta: float) -> void:
	tick(delta)


func show_upgrade_hint(value: bool) -> void:
	upgrade_label.visible = value
