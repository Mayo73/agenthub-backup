extends "res://tests/base_test.gd"

var main: Main


func setup() -> void:
	main = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Main
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_prototyp_hinweis() -> void:
	check(main.banner.text.contains("PROTOTYP"), "Kopfzeile kennzeichnet den Prototyp")
	check(main.banner.text.contains("Testprofile"), "Kopfzeile nennt die Testprofile")


func test_startet_mit_entdecken() -> void:
	check_eq(main.current_screen, "entdecken", "erster Bildschirm")
	check_eq(main.tab_buttons.size(), 3, "Reiter")
	check(main.tab_buttons["entdecken"].disabled, "aktiver Reiter ist gesperrt")


func test_reiter_symbole() -> void:
	check(main.tab_buttons["matches"].text.contains("♥"), "Matches-Button enthält Symbol ♥")
	check(main.tab_buttons["matches"].text.contains("Matches"), "Matches-Button enthält Text Matches")
	check(main.tab_buttons["entdecken"].text.contains("✦"), "Entdecken-Button enthält Symbol ✦")
	check(main.tab_buttons["entdecken"].text.contains("Entdecken"), "Entdecken-Button enthält Text Entdecken")
	check(main.tab_buttons["profil"].text.contains("●"), "Profil-Button enthält Symbol ●")
	check(main.tab_buttons["profil"].text.contains("Profil"), "Profil-Button enthält Text Profil")
	check(main.tab_buttons["entdecken"].disabled, "Entdecken-Reiter ist gesperrt am Start")


func test_reiter_wechselt_bildschirm() -> void:
	main.tab_buttons["profil"].pressed.emit()
	check_eq(main.current_screen, "profil", "nach Klick auf Profil")
	check_eq(main.content.get_child_count(), 1, "genau ein Bildschirm im Inhaltsbereich")
	check(not main.tab_buttons["entdecken"].disabled, "Entdecken wieder klickbar")


const TEST_PATH := "user://test_main.json"


func test_entdecken_ist_echt() -> void:
	main.use_store(TEST_PATH)
	check(main.screen is DiscoverScreen, "Entdecken zeigt den echten Bildschirm")
	DirAccess.remove_absolute(TEST_PATH)


func test_wechsel_speichert() -> void:
	main.use_store(TEST_PATH)
	main._on_switched("p02")
	check_eq(main.state.active_id, "p02", "aktive Person")
	check_eq(StateStore.load_state(TEST_PATH).active_id, "p02", "gespeicherte aktive Person")
	check(main.screen is DiscoverScreen, "Entdecken nach dem Wechsel")
	DirAccess.remove_absolute(TEST_PATH)


func test_interesse_wird_gespeichert() -> void:
	main.use_store(TEST_PATH)
	(main.screen as DiscoverScreen).like_button.pressed.emit()
	check(StateStore.load_state(TEST_PATH).book.likes.has("p01>p02"), "Interesse gespeichert")
	DirAccess.remove_absolute(TEST_PATH)


func test_profil_ist_echt() -> void:
	main.use_store(TEST_PATH)
	main.show_screen("profil")
	check(main.screen is ProfileScreen, "Profil ist der echte Bildschirm")
	DirAccess.remove_absolute(TEST_PATH)


func test_profil_wird_gespeichert() -> void:
	main.use_store(TEST_PATH)
	main.show_screen("profil")
	var ps = main.screen as ProfileScreen
	ps.name_edit.text = "Alexa"
	ps.save_button.pressed.emit()

	var loaded = StateStore.load_state(TEST_PATH)
	check_eq(loaded.profile("p01").name, "Alexa", "Name im Load")
	check(main.perspective.picker.get_item_text(0).begins_with("Du bist: Alexa"), "Perspektive zeigt neuen Namen")
	DirAccess.remove_absolute(TEST_PATH)


func test_zuruecksetzen() -> void:
	main.use_store(TEST_PATH)
	main.state.like("p02")
	main.save()
	check(not main.state.book.likes.is_empty(), "Likes vor dem Zurücksetzen")

	main.show_screen("profil")
	var ps = main.screen as ProfileScreen
	ps.reset_button.pressed.emit()
	ps.dialog.ok_button.pressed.emit()

	check(main.state.book.likes.is_empty(), "Nach Reset sind Likes leer")
	check_eq(main.current_screen, "entdecken", "Zurücksetzen zeigt Entdecken")
	check(StateStore.load_state(TEST_PATH).book.likes.is_empty(), "Gespeicherte Datei hat keine Likes")
	DirAccess.remove_absolute(TEST_PATH)


## Erzeugt das Match m1 zwischen p01 und p02 und speichert es.
func make_match() -> void:
	main.state.like("p02")
	main.state.switch_to("p02")
	main.state.like("p01")
	main.state.switch_to("p01")
	main.save()


func test_matches_ist_echt() -> void:
	main.use_store(TEST_PATH)
	make_match()
	main.show_screen("matches")
	check(main.screen is MatchesScreen, "Matches zeigt den echten Bildschirm")
	check_eq((main.screen as MatchesScreen).rows.size(), 1, "ein Match in der Liste")
	DirAccess.remove_absolute(TEST_PATH)


func test_chat_oeffnen_und_zurueck() -> void:
	main.use_store(TEST_PATH)
	make_match()
	main.show_screen("matches")
	(main.screen as MatchesScreen).rows["m1"].pressed.emit()
	check(main.screen is ChatScreen, "Klick auf das Match öffnet den Chat")
	check_eq(main.current_screen, "chat", "aktueller Bildschirm")
	check(main.tab_buttons["matches"].disabled, "Reiter Matches bleibt aktiv markiert")
	check(not main.tab_buttons["entdecken"].disabled, "Entdecken klickbar")
	(main.screen as ChatScreen).back_button.pressed.emit()
	check(main.screen is MatchesScreen, "Zurück führt zur Liste")
	DirAccess.remove_absolute(TEST_PATH)


func test_nachricht_gespeichert() -> void:
	main.use_store(TEST_PATH)
	make_match()
	main.show_chat("m1")
	var chat := main.screen as ChatScreen
	chat.input.text = "Hallo"
	chat.send_button.pressed.emit()
	check_eq(StateStore.load_state(TEST_PATH).chat.count_for("m1"), 1, "Nachricht gespeichert")
	DirAccess.remove_absolute(TEST_PATH)


func test_wechsel_im_chat() -> void:
	main.use_store(TEST_PATH)
	make_match()
	main.show_chat("m1")
	main._on_switched("p03")
	check_eq(main.current_screen, "matches", "Wechsel im Chat führt zur Liste")
	check_eq((main.screen as MatchesScreen).rows.size(), 0, "p03 hat keine Matches")
	DirAccess.remove_absolute(TEST_PATH)

func test_treffen_oeffnen() -> void:
	main.use_store(TEST_PATH)
	make_match()
	main.show_chat("m1")
	(main.screen as ChatScreen).meeting_button.pressed.emit()
	check(main.screen is MeetingScreen, "Knopf Treffen öffnet den Treffvorschlag")
	check_eq(main.current_screen, "treffen", "aktueller Bildschirm")
	(main.screen as MeetingScreen).back_button.pressed.emit()
	check(main.screen is ChatScreen, "Zurück führt in den Chat")
	DirAccess.remove_absolute(TEST_PATH)


func test_treffen_gespeichert() -> void:
	main.use_store(TEST_PATH)
	make_match()
	main.show_meeting("m1")
	var meeting := main.screen as MeetingScreen
	meeting.place_edit.text = "Stadtpark"
	meeting.date_edit.text = "24.10.2026"
	meeting.time_edit.text = "10:30"
	meeting.form_picker.select(1)
	meeting.propose_button.pressed.emit()
	check_eq(StateStore.load_state(TEST_PATH).meetings.get_meeting("m1").get("place", ""), "Stadtpark", "Treffvorschlag gespeichert")
	DirAccess.remove_absolute(TEST_PATH)


func test_match_oeffnet_chat() -> void:
	main.use_store(TEST_PATH)
	main.state.switch_to("p02")
	main.state.like("p01")  # p02 likes p01
	main.state.switch_to("p01")

	main.show_screen("entdecken")
	var discover := main.screen as DiscoverScreen
	discover.like_button.pressed.emit()  # P01 liket p02 → neues Match m2

	check(discover.match_overlay.visible, "match_overlay soll sichtbar sein")
	check(discover.match_overlay.text_label.text.contains("Sam"), "Text enthält 'Sam'")
	discover.match_overlay.write_button.pressed.emit()

	# current_screen sollte auf "chat" wechseln
	check_eq(main.current_screen, "chat", "current_screen ist 'chat' nach Write-Klick")

	DirAccess.remove_absolute(TEST_PATH)


func test_reiter_zahl_start() -> void:
	## Nach dem Start mit frischem Demozustand ist tab_buttons["matches"].text gleich
	## "♥\nMatches", ergänzt um " · n", wenn n (Zahl der laufenden Matches aus state.my_matches()) größer 0 ist.
	main.reset_demo()
	var anzahl := 0
	for m in main.state.my_matches():
		if m.get("ended_by", "") == "":
			anzahl += 1
	var expected := Main.TAB_ICONS["matches"] + "\n" + Main.TAB_TITLES["matches"]
	if anzahl > 0:
		expected += " · %d" % anzahl
	check_eq(main.tab_buttons["matches"].text, expected, "Reiter zeigt korrekte Anzahl am Start")


func test_reiter_zaehlt_match() -> void:
	## Zwei Testpersonen gegenseitig liken (wie in den bestehenden Tests), danach update_badges() → Text endet auf " · %d" % n mit n ≥ 1 aus state.my_matches().
	main.use_store(TEST_PATH)
	make_match()
	var anzahl := 0
	for m in main.state.my_matches():
		if m.get("ended_by", "") == "":
			anzahl += 1
	check(anzahl >= 1, "es gibt mindestens ein laufendes Match")
	main.update_badges()
	var expected_suffix := " · %d" % anzahl
	check(main.tab_buttons["matches"].text.ends_with(expected_suffix), "Reiter zeigt korrekte Anzahl nach update_badges()")
	DirAccess.remove_absolute(TEST_PATH)
