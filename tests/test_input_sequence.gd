extends "res://tests/base_test.gd"

var seq: InputSequence

func setup() -> void:
	seq = InputSequence.new()
	seq.hold("rechts", 0, 120)
	seq.hold("springen", 40, 60)

func test_gehalten() -> void:
	check_eq(seq.pressed_at(0), ["rechts"], "bei Schritt 0 nur rechts")
	check_eq(seq.pressed_at(50), ["rechts", "springen"], "bei Schritt 50 beide gedrückt")
	check_eq(seq.pressed_at(60), ["rechts"], "bei Schritt 60 springen los, nur noch rechts")
	check_eq(seq.pressed_at(119), ["rechts"], "bei Schritt 119 immer noch rechts")
	check_eq(seq.pressed_at(120), [], "bei Schritt 120 keine Taste mehr gedrückt")

func test_ereignisse() -> void:
	var evs = seq.events()
	check_eq(evs.size(), 4, "genau 4 Ereignisse")
	var first = evs[0]
	check_eq(first["step"], 0, "erstes Ereignis bei Schritt 0")
	check_eq(first["action"], "rechts", "erstes Ereignis für rechts")
	check(first["pressed"], "erstes Ereignis pressed true")
	var last = evs[-1]
	check_eq(last["step"], 120, "letztes Ereignis bei Schritt 120")
	check_eq(last["action"], "rechts", "letztes Ereignis für rechts")
	check(!last["pressed"], "letztes Ereignis pressed false")

func test_laenge() -> void:
	check_eq(seq.length(), 120, "Länge ist 120")

func test_abbruch() -> void:
	var ab = seq.abort(50)
	check_eq(ab.size(), 2, "abort bei Schritt 50 liefert 2 Ereignisse")
	for e in ab:
		check(!e["pressed"], "Abort-Ereignisse pressed false")
	var actions = ["rechts", "springen"]
	for a in actions:
		var found = false
		for e in ab:
			if e["action"] == a:
				found = true
				break
		check(found, "Abort enthält Ereignis für: " + a)
	var empty_abort = seq.abort(200)
	check_eq(empty_abort.size(), 0, "abort bei Schritt 200 leer")

func test_tippen() -> void:
	seq.tap("schuss", 10)
	check(seq.is_pressed("schuss", 10), "nach tap ist Taste bei 10 gedrückt")
	check(!seq.is_pressed("schuss", 11), "nach tap ist Taste bei 11 nicht gedrückt")

func test_ungueltig() -> void:
	var vor_size = seq.holds.size()
	seq.hold("x", 5, 5)
	check_eq(seq.holds.size(), vor_size, "hold mit to==from ignoriert")

func test_speichern_laden() -> void:
	var d = seq.to_dict()
	var json_str := JSON.stringify(d)
	var parsed = JSON.parse_string(json_str)
	var loaded = InputSequence.from_dict(parsed)
	check_eq(loaded.pressed_at(50), seq.pressed_at(50), "geladene Sequenz gleiche Pressed-States")
	check(typeof(loaded.holds[0]["from"]) == TYPE_INT, "holds[from] ist INT")
