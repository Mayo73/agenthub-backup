extends "res://tests/base_test.gd"

var menu: EvolveMenu
var b: FishBuild
var p: FishProgress


func setup() -> void:
	menu = EvolveMenu.new()
	b = FishBuild.new()
	p = FishProgress.new()


func teardown() -> void:
	menu.free()


func test_zeilentext() -> void:
	## Schwanzflosse hat Stufe 0, Kosten für nächste Stufe sind 10 DNA
	check_eq(EvolveMenu.row_text(b, "schwanz"), "Schwanzflosse: Stufe 0 → 1 (10 DNA)", "Zeile für Schwanzflosse")
	## Nach dreimaligem Upgraden hat "augen" Stufe 3 (höchste)
	b.upgrade("augen")
	b.upgrade("augen")
	b.upgrade("augen")
	check_eq(EvolveMenu.row_text(b, "augen"), "Augen: Stufe 3 (höchste Stufe)", "Zeile für Augen bei höchster Stufe")


func test_neu_versteckt() -> void:
	## Neue Instanz ist unsichtbar
	check(not menu.visible, "menu.visible ist false")
	## Es gibt 5 Knöpfe für die 5 Bauteile
	check_eq(menu.buttons.size(), 5, "menu.buttons.size() ist 5")
	## Titel ist "Entwicklung"
	check_eq(menu.title_label.text, "Entwicklung", "menu.title_label.text ist Entwicklung")


func test_oeffnen() -> void:
	p.dna = 15
	menu.open(b, p)
	## Menü ist sichtbar
	check(menu.visible, "menu.visible ist true nach open()")
	## DNA-Anzeige zeigt den richtigen Wert
	check_eq(menu.dna_label.text, "DNA: 15", "dna_label.text ist DNA: 15")
	## Schwanzflosse kann verbessert werden (kostet 10, wir haben 15)
	check(not menu.buttons["schwanz"].disabled, "menu.buttons[\"schwanz\"].disabled ist false")


func test_zu_teuer_gesperrt() -> void:
	p.dna = 5
	menu.open(b, p)
	## Kiefer kostet 10 DNA, wir haben nur 5 → gesperrt
	check(menu.buttons["kiefer"].disabled, "menu.buttons[\"kiefer\"].disabled ist true")


func test_verbessern() -> void:
	p.dna = 30
	menu.open(b, p)
	## Signal upgraded mit einem Array-Zähler verbinden
	var counter := [0]
	menu.upgraded.connect(func(slot): counter[0] += 1)
	## Knopf für Brustflossen drücken
	menu.buttons["flossen"].pressed.emit()
	## Brustflosse hat jetzt Stufe 1
	check_eq(b.level("flossen"), 1, "b.level(\"flossen\") ist 1")
	## DNA wurde um 20 reduziert (Preis für Stufe 1)
	check_eq(p.dna, 20, "p.dna ist 20")
	## Signal wurde einmal empfangen
	check_eq(counter[0], 1, "Signal upgraded einmal empfangen")
	## Beschriftung zeigt neue Stufe und Kosten für nächstes Upgrade
	check_eq(menu.labels["flossen"].text, "Brustflossen: Stufe 1 → 2 (20 DNA)", "labels[\"flossen\"].text nach Upgrade")


func test_schliessen() -> void:
	menu.open(b, p)
	## Signal closed zählen
	var counter := [0]
	menu.closed.connect(func(): counter[0] += 1)
	## Über close_button schließen
	menu.close_button.pressed.emit()
	## Menü ist unsichtbar
	check(not menu.visible, "menu.visible ist false nach close_button.pressed")
	## Signal einmal empfangen
	check_eq(counter[0], 1, "Signal closed einmal empfangen")
	## close() noch einmal aufrufen
	menu.close()
	## Sollte weiterhin nur einmal sein (kein Duplikat)
	check_eq(counter[0], 1, "Signal closed weiterhin einmal nach erneutem close()")
