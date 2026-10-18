extends "res://tests/base_test.gd"

var chat: ChatLog


func setup() -> void:
	chat = ChatLog.new()


func test_senden() -> void:
	check(chat.send("m1", "p01", "Hallo"), "send gibt true zurück")
	check_eq(chat.messages_for("m1").size(), 1, "eine Nachricht gespeichert")
	var msg := chat.messages_for("m1")[0]
	check(msg["text"] == "Hallo", "Text korrekt")
	check(msg["from"] == "p01", "Absender korrekt")
	check(msg["n"] == 1, "erstes n = 1")


func test_leer_abgelehnt() -> void:
	chat = ChatLog.new()
	check(not chat.send("m1", "p01", "   "), "leerer Text wird abgelehnt")
	check_eq(chat.messages_for("m1").size(), 0, "keine Nachricht gespeichert")


func test_leerzeichen_entfernt() -> void:
	chat = ChatLog.new()
	var ok := chat.send("m1", "p01", "  Hi  ")
	check(ok, "send gibt true zurück")
	var msg := chat.messages_for("m1")[0]
	check(msg["text"] == "Hi", "Leerzeichen entfernt")


func test_zu_lang_gekuerzt() -> void:
	chat = ChatLog.new()
	var long_text := ""
	for _i in range(600):
		long_text += "a"
	var ok := chat.send("m1", "p01", long_text)
	check(ok, "send gibt true zurück")
	var msg := chat.messages_for("m1")[0]
	check(msg["text"].length() == 500, "Text auf MAX_LENGTH gekürzt")


func test_getrennt_nach_match() -> void:
	chat = ChatLog.new()
	chat.send("m1", "p01", "Nachricht 1")
	chat.send("m1", "p02", "Nachricht 2")
	chat.send("m2", "p01", "Match 2")
	check_eq(chat.count_for("m1"), 2, "zwei Nachrichten in m1")
	check_eq(chat.count_for("m2"), 1, "eine Nachricht in m2")
	check_eq(chat.count_for("m3"), 0, "keine Nachrichten in m3")


func test_reihenfolge_und_letzte() -> void:
	chat = ChatLog.new()
	chat.send("m1", "p01", "eins")
	chat.send("m1", "p02", "zwei")
	chat.send("m1", "p01", "drei")
	var msgs: Array[Dictionary] = chat.messages_for("m1")
	check(msgs[0]["text"] == "eins", "erste Nachricht")
	check(msgs[1]["text"] == "zwei", "zweite Nachricht")
	check(msgs[2]["text"] == "drei", "dritte Nachricht")
	var last := chat.last_message("m1")
	check(last["text"] == "drei", "letzte Nachricht ist drei")
	check(chat.last_message("m9").is_empty(), "leere Nachricht bei nicht vorhandenem Match")


func test_speichern_laden() -> void:
	chat = ChatLog.new()
	chat.send("m1", "p01", "Nachricht 1")
	chat.send("m1", "p02", "Nachricht 2")
	var saved := chat.to_dict()
	var loaded := ChatLog.from_dict(saved)
	check_eq(loaded.messages_for("m1").size(), 2, "beide Nachrichten geladen")
	for i in range(2):
		check_eq(loaded.messages_for("m1")[i]["text"], chat.messages_for("m1")[i]["text"], "Text %d identisch" % [i])
	var new_ok := loaded.send("m1", "p01", "Nachricht 3")
	check(new_ok, "send gibt true zurück")
	check_eq(loaded.messages_for("m1")[-1]["n"], 3, "neue Nachricht hat n = 3")
