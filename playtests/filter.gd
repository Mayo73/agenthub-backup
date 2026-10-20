extends Playtest
## Filter nach Sportart und Erfahrung, Leerzustand, Neustart


const STORE := "user://spieltest_filter.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Filter nach Sportart und Erfahrung, Leerzustand, Neustart"


func run() -> void:
	# Zu Beginn löschen, falls vorhanden
	var da := DirAccess.open("user://")
	if da.file_exists("spieltest_filter.json"):
		da.remove("spieltest_filter.json")

	scene.use_store(STORE)

	var d: DiscoverScreen = scene.screen as DiscoverScreen

	# 1. Boxen filtern (Index 3 = Boxen, Level 0 = Jede Erfahrung)
	d.set_filter(3, 0)
	await wait(0.3)
	check(d.current().id == "p03", "Filter Boxen zeigt Mira")
	shot("filter_boxen")

	# 2. Boxen + Einsteiger (Index 1 = Einsteiger, da 0=Jede Erfahrung)
	# Filter Boxen ist bei Index 3, für Einsteiger muss Level-Index auf 1 gesetzt werden
	d.set_filter(3, 1)
	await wait(0.3)
	check(d.empty_label.visible and d.empty_label.text.contains("Ändere den Filter"), "Leerzustand bei unpassendem Filter")
	shot("filter_leer")

	# 3. Zurück zu Boxen (alle Level), dann Neustart
	d.set_filter(3, 0)
	await reload_scene()
	scene.use_store(STORE)
	d = scene.screen as DiscoverScreen
	check(scene.state.filter.art == "Boxen", "Filter nach Neustart erhalten")
	check(d.art_filter.selected == 3, "Auswahl zeigt den Filter")

	# 4. Ohne Filter (Index 0 = Alle Sportarten, Index 0 = Jede Erfahrung)
	d.set_filter(0, 0)
	await wait(0.3)
	check(d.current().id == "p02", "Ohne Filter wieder alle")

	# Am Ende speichern löschen
	var dir := DirAccess.open("user://")
	if dir.file_exists("spieltest_filter.json"):
		dir.remove("spieltest_filter.json")
