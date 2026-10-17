class_name EvolveMenu
extends CanvasLayer
## Entwicklungsmenü der Fischphase: je Bauteil eine Zeile mit Stufe, Preis und Knopf "Verbessern".

signal upgraded(slot: String)
signal closed

var build: FishBuild
var progress: FishProgress
var title_label: Label
var dna_label: Label
var rows: VBoxContainer
## Bauteil -> Knopf "Verbessern"
var buttons := {}
## Bauteil -> Beschriftung der Zeile
var labels := {}
var close_button: Button


## Text einer Zeile, z. B. "Schwanzflosse: Stufe 1 → 2 (20 DNA)" oder "Augen: Stufe 3 (höchste Stufe)".
static func row_text(b: FishBuild, slot: String) -> String:
	var c := FishUpgrades.cost(b, slot)
	if c < 0:
		return "%s: Stufe %d (höchste Stufe)" % [FishBuild.NAMES[slot], b.level(slot)]
	return "%s: Stufe %d → %d (%d DNA)" % [FishBuild.NAMES[slot], b.level(slot), b.level(slot) + 1, c]


func _init() -> void:
	layer = 20
	## Halbdurchsichtiger dunkler Hintergrund über das ganze Bild
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.02, 0.12, 0.18, 0.88)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	## Hauptcontainer mit den Elementen
	rows = VBoxContainer.new()
	rows.name = "Rows"
	rows.position = Vector2(560, 160)
	rows.add_theme_constant_override("separation", 10)
	add_child(rows)
	## Titel "Entwicklung"
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Entwicklung"
	title_label.add_theme_font_size_override("font_size", 44)
	rows.add_child(title_label)
	## DNA-Anzeige
	dna_label = Label.new()
	dna_label.name = "DNA"
	dna_label.add_theme_font_size_override("font_size", 28)
	rows.add_child(dna_label)
	## Container für die Bauteil-Zeilen (bereits oben als rows deklariert)
	var slot_rows := VBoxContainer.new()
	slot_rows.name = "SlotRows"
	slot_rows.add_theme_constant_override("separation", 6)
	rows.add_child(slot_rows)
	## Für jedes Bauteil eine Zeile mit Label und Button
	for slot: String in FishBuild.SLOTS:
		var hbox := HBoxContainer.new()
		hbox.name = "%s_row" % slot
		var label := Label.new()
		label.name = "%s_label" % slot
		label.text = row_text(FishBuild.new(), slot)
		label.custom_minimum_size = Vector2(520, 0)
		label.add_theme_font_size_override("font_size", 26)
		hbox.add_child(label)
		var btn := Button.new()
		btn.name = "%s_btn" % slot
		btn.text = "Verbessern"
		btn.pressed.connect(try_upgrade.bind(slot))
		hbox.add_child(btn)
		slot_rows.add_child(hbox)
		labels[slot] = label
		buttons[slot] = btn
	## Schließen-Knopf "Weiterschwimmen"
	close_button = Button.new()
	close_button.name = "Close"
	close_button.text = "Weiterschwimmen"
	close_button.custom_minimum_size = Vector2(400, 56)
	close_button.pressed.connect(close)
	rows.add_child(close_button)
	## Am Ende unsichtbar
	visible = false


## Öffnet das Menü mit dem aktuellen Build und Progress.
func open(b: FishBuild, p: FishProgress) -> void:
	build = b
	progress = p
	refresh()
	visible = true


## Aktualisiert alle Anzeigen basierend auf build und progress.
func refresh() -> void:
	dna_label.text = "DNA: %d" % progress.dna
	for slot: String in FishBuild.SLOTS:
		labels[slot].text = row_text(build, slot)
		buttons[slot].disabled = not FishUpgrades.can_upgrade(build, progress, slot)


## Versucht, das Bauteil zu verbessern. Gibt true bei Erfolg zurück.
func try_upgrade(slot: String) -> bool:
	if not FishUpgrades.upgrade(build, progress, slot):
		return false
	refresh()
	upgraded.emit(slot)
	return true


## Schließt das Menü.
func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()
