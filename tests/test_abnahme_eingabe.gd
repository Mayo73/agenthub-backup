extends "res://tests/base_test.gd"

var seq: InputSequence

func setup() -> void:
	seq = InputSequence.new()
	seq.hold("rechts", 0, 120)
	seq.hold("springen", 30, 60)


func test_gehalten() -> void:
	check(seq.is_pressed("rechts", 0), "rechts muss bei Schritt 0 gedrückt sein")
	check(seq.is_pressed("rechts", 119), "rechts muss bei Schritt 119 gedrückt sein")
	check(not seq.is_pressed("rechts", 120), "rechts darf bei Schritt 120 nicht gedrückt sein")

	var gezählt: int = 0
	for i in range(200):
		if seq.is_pressed("rechts", i):
			gezählt += 1
	check_eq(gezählt, 120, "muss genau 120 Schritte mit rechts zählen")


func test_kombiniert() -> void:
	var pressed_45 := seq.pressed_at(45)
	check(pressed_45.has("rechts"), "pressed_at(45) muss 'rechts' enthalten")
	check(pressed_45.has("springen"), "pressed_at(45) muss 'springen' enthalten")

	var pressed_70 := seq.pressed_at(70)
	check_eq(pressed_70.size(), 1, "pressed_at(70) muss nur eine Aktion haben")
	check(pressed_70.has("rechts"), "pressed_at(70) muss 'rechts' enthalten")


func test_abbruch() -> void:
	var abgebrochen_45 := seq.abort(45)
	check_eq(abgebrochen_45.size(), 2, "abort(45) muss zwei Einträge liefern")
	check(not abgebrochen_45[0].pressed, "erste Meldung muss pressed:false haben")
	check(not abgebrochen_45[1].pressed, "zweite Meldung muss pressed:false haben")

	# Nach sortierung (aufsteigend nach action): 'rechts' kommt vor 'springen'
	check_eq(abgebrochen_45[0].action, "rechts", "erste Aktion muss 'rechts' sein")
	check_eq(abgebrochen_45[1].action, "springen", "zweite Aktion muss 'springen' sein")

	var abgebrochen_130 := seq.abort(130)
	check_eq(abgebrochen_130.size(), 0, "abort(130) muss leer sein")
