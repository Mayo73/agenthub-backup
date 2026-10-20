extends Playtest
## Spieltest prüft, dass die Ortsskizze im Treffvorschlag mit dem eingegebenen Ort wechselt.


const STORE := "user://spieltest_ortsskizze.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Ortsskizze im Treffvorschlag"


func run() -> void:
	await wait(0.3)

	var da: DirAccess = DirAccess.open("user://")
	if da.file_exists("spieltest_ortsskizze.json"):
		da.remove("spieltest_ortsskizze.json")

	scene.use_store("user://spieltest_ortsskizze.json")

	scene.state.like("p02")
	scene.state.switch_to("p02")
	await wait(0.3)
	scene.state.like("p01")
	await wait(0.3)
	scene._on_switched("p01")

	await wait(0.3)
	scene.tab_buttons["matches"].pressed.emit()

	await wait(0.3)
	var matches = scene.screen as MatchesScreen
	matches.rows["m1"].pressed.emit()

	await wait(0.3)
	var chat = scene.screen as ChatScreen
	chat.meeting_button.pressed.emit()

	await wait(0.3)
	var ms: MeetingScreen = scene.screen as MeetingScreen

	check(ms.place_view.kind == "Draußen", "Ohne Ort neutrale Skizze")
	check(ms.days_label.text != "", "Gemeinsame Tage angezeigt")

	var ort_art_paare := [
		["Stadtpark, Wiese am Teich", "Park"],
		["Strand am Badesee", "Strand"],
		["Sportplatz an der Schule", "Sportplatz"],
		["Waldweg am Hügel", "Wald"]
	]

	for ort_art in ort_art_paare:
		ms.place_edit.text = ort_art[0]
		ms.place_edit.text_changed.emit(ort_art[0])
		await wait(0.2)
		check(ms.place_view.kind == ort_art[1], "Skizze %s" % ort_art[1])
		shot("skizze_" + ort_art[1].to_lower())

	da.remove_absolute("user://spieltest_ortsskizze.json")
