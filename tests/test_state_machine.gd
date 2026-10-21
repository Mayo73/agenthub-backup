extends "res://tests/base_test.gd"

var sm: StateMachine


func setup() -> void:
	sm = StateMachine.new("idle")
	sm.add("idle", "laufen", "walk")
	sm.add("walk", "stopp", "idle")
	sm.add("*", "treffer", "hurt")


func test_wechsel() -> void:
	check(sm.send("laufen"), "erster Übergang laufen soll wahr sein")
	check_eq(sm.current, "walk", "current soll nach Lauf zu walk wechseln")
	var zweite_send := sm.send("laufen")
	check(not zweite_send, "zweiter Laufflug soll false zurückgeben")
	check_eq(sm.current, "walk", "current soll nach fehlgeschlagenem Lauf gleich bleiben")


func test_jederzeit() -> void:
	check(sm.send("treffer"), "Trefferübergang soll jederzeit möglich sein")
	check_eq(sm.current, "hurt", "current soll auf hurt wechseln")


func test_ereignisse() -> void:
	var ev := sm.events()
	check(ev.has("laufen"), "events soll 'laufen' enthalten")
	check(ev.has("treffer"), "events soll 'treffer' enthalten")
	check(not ev.has("stopp"), "events soll 'stopp' im aktuellen Zustand nicht enthalten")
	check(not sm.can("stopp"), "can('stopp') soll false sein, da vom idle kein Übergang existiert")


func test_verlauf() -> void:
	sm.send("laufen")
	sm.send("stopp")
	var expected := ["idle", "walk", "idle"]
	check_eq(sm.history, expected, "history soll [\"idle\", \"walk\", \"idle\"] sein")


func test_speichern() -> void:
	sm.send("laufen")
	var d := sm.to_dict()
	var loaded := StateMachine.from_dict(d)
	check_eq(loaded.current, "walk", "geladener Zustand soll current='walk' haben")
	var erfolg := loaded.send("stopp")
	check(erfolg, "send('stopp') nach dem Laden soll wahr sein")
