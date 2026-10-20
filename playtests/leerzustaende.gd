extends Playtest
## Spieltest für Leerzustände: keine Profile, keine Matches, keine Nachrichten und Hinweis bei unvollständigem Treffvorschlag.

const STORE := "user://spieltest_leer.json"

func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Leerzustände und Hinweis bei unvollständigem Treffvorschlag"


func run() -> void:
	# Eigene Speicherdatei zu Beginn löschen, falls vorhanden
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
	scene.use_store(STORE)

	await wait(0.3)

	# 1. Matches-Reiter: Hinweis noch keine Matches
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	check((scene.screen as MatchesScreen).empty_label.visible, "Hinweis: noch keine Matches")
	shot("keine_matches")

	# 2. Als Sam: Profile swipen bis Leerzustand Entdecken
	scene._on_switched("p02")
	await wait(0.3)
	scene.state.like("p01")
	await wait(0.3)
	scene._on_switched("p01")
	await wait(0.3)
	scene.tab_buttons["entdecken"].pressed.emit()
	await wait(0.3)

	var discover: DiscoverScreen = scene.screen as DiscoverScreen
	discover.like_button.pressed.emit()  # Match mit Sam
	await wait(0.3)
	for _i in range(6):
		discover.pass_button.pressed.emit()
		await wait(0.3)

	check((scene.screen as DiscoverScreen).empty_label.visible, "Hinweis: keine weiteren Profile")
	shot("keine_profile")

	# 3. Matches-Reiter, erste Zeile drücken → Chat mit leerer Nachricht
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	(scene.screen as MatchesScreen).rows["m1"].pressed.emit()
	await wait(0.3)
	check((scene.screen as ChatScreen).empty_label.visible, "Hinweis: noch keine Nachrichten")
	shot("keine_nachrichten")

	# 4. Treffvorschlag öffnen → Hinweis kein Treffvorschlag
	(scene.screen as ChatScreen).meeting_button.pressed.emit()
	await wait(0.3)
	var ms: MeetingScreen = scene.screen as MeetingScreen
	check(ms.status_label.text == "Noch kein Treffvorschlag.", "Hinweis: noch kein Treffvorschlag")

	# 5. Unvollständigen Vorschlag machen (nur Ort, kein Datum)
	ms.place_edit.text = "Stadtpark"
	await wait(0.3)
	ms.propose_button.pressed.emit()
	await wait(0.3)

	check(ms.error_label.text.contains("Datum fehlt"), "Hinweis bei unvollständigem Vorschlag")
	check(scene.state.meetings.get_meeting("m1").is_empty(), "Unvollständiger Vorschlag nicht gespeichert")
	shot("treffen_unvollstaendig")

	# Eigene Speicherdatei am Ende löschen
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
