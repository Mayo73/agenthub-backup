extends Playtest
## Spieltest: Blockieren einer Testperson – keine Kontaktmöglichkeit mehr aus beiden Perspektiven.


const STORE := "user://spieltest_blockieren.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Blockieren beendet jeden Kontakt, aus beiden Perspektiven"


func _remove_store() -> void:
	var path := ProjectSettings.globalize_path(STORE)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func run() -> void:
	_remove_store()
	scene.use_store(STORE)
	await wait(0.3)

	# 1. Match p01/p02 direkt über den Zustand aufbauen
	scene.state.like("p02")
	scene.state.switch_to("p02")
	scene.state.like("p01")
	scene._on_switched("p01")
	await wait(0.3)

	# 2. Zu Matches navigieren und m1 öffnen, Chat erhalten
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	(scene.screen as MatchesScreen).rows["m1"].pressed.emit()
	await wait(0.3)
	var chat := scene.screen as ChatScreen
	check(chat != null, "Chat geöffnet")
	await wait(0.3)

	# 3. Block-Knopf drücken, Rückfragedialog erscheint
	chat.block_button.pressed.emit()
	await wait(0.3)
	check(chat.dialog.visible, "Rückfrage vor dem Blockieren")
	shot("rueckfrage")
	await wait(0.3)

	# 4. Bestätigen und Auswirkungen prüfen
	chat.dialog.ok_button.pressed.emit()
	await wait(0.3)
	check(scene.state.book.is_blocked("p01", "p02"), "Sam ist blockiert")
	check(chat.closed_label.visible, "Chat zeigt, dass kein Kontakt mehr möglich ist")
	check(chat.send_button.disabled, "Senden gesperrt")
	shot("blockiert")

	# 5. Perspektivwechsel zu p02 und Prüfung der anderen Seite
	scene._on_switched("p02")
	await wait(0.3)
	var ids: Array[String] = scene.state.book.candidates(scene.state.active_id, scene.state.all_ids())
	check(not ids.has("p01"), "Alex erscheint bei Sam nicht mehr unter Entdecken")
	check(not scene.state.can_write("m1"), "Sam kann Alex nicht mehr schreiben")

	# 6. Als p02 auf Entdecken navigieren und shot machen
	scene.tab_buttons["entdecken"].pressed.emit()
	await wait(0.3)
	shot("entdecken_sam")

	_remove_store()
