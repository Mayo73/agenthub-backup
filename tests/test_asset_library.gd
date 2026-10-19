extends "res://tests/base_test.gd"

var lib: AssetLibrary


func setup() -> void:
	lib = AssetLibrary.new()


func test_art() -> void:
	check_eq(AssetLibrary.kind_of("res://a/Held.PNG"), "bild", "PNG als bild erkannt")
	check_eq(AssetLibrary.kind_of("x.glb"), "modell", "GLB als modell erkannt")
	check_eq(AssetLibrary.kind_of("x.txt"), "", "TXT als leer erkannt")


func test_aufnehmen() -> void:
	var ergebnis := lib.add("res://bilder/held.png")
	check(ergebnis.is_ok(), "add erfolgreich für existierende Erweiterung")

	var data := ergebnis.data
	check_eq(data["id"], "a1", "ID ist a1")

	var liste := lib.list()
	check_eq(liste.size(), 1, "Ein Asset in Liste")
	check_eq(liste[0]["name"], "held", "Name aus Pfad abgeleitet")


func test_nicht_unterstuetzt() -> void:
	var ergebnis := lib.add("x.bmp")
	check(not ergebnis.is_ok(), "Fehler bei nicht unterstütztem Format")
	check_eq(ergebnis.code, "invalid_argument", "Code ist invalid_argument")
	check(ergebnis.message.contains("Format .bmp wird nicht unterstützt"), "Meldung enthält Information über bmp")


func test_doppelt() -> void:
	lib.add("res://bilder/held.png")
	var ergebnis := lib.add("res://bilder/held.png")

	check(not ergebnis.is_ok(), "Fehler bei doppeltem Pfad")
	check_eq(ergebnis.code, "conflict", "Code ist conflict")


func test_filter_und_suche() -> void:
	lib = AssetLibrary.new()

	lib.add("held.png")
	lib.add("musik.ogg")
	lib.add("burg.glb", "Große Burg")

	var liste_audio := lib.list("audio")
	check_eq(liste_audio.size(), 1, "Nur ein Audio-Asset")

	var ergebnis_suche := lib.find("burg")
	check_eq(ergebnis_suche, ["a3"], "Suche nach burg findet a3")


func test_entfernen() -> void:
	lib = AssetLibrary.new()

	lib.add("held.png")
	check(lib.remove("a1"), "remove gibt true zurück bei existierendem ID")

	check_eq(lib.list().size(), 0, "Liste leer nach Entfernen")

	check(not lib.remove("a1"), "remove gibt false bei nicht existierender ID")


func test_supported_text() -> void:
	var text := AssetLibrary.supported_text()
	check(text.contains("Bilder: png, jpg, webp"), "Text enthält Bilder")
	check(text.contains("Audio: ogg, wav, mp3"), "Text enthält Audio")
	check(text.contains("Modelle: glb, gltf"), "Text enthält Modelle")


func test_list_sortierung() -> void:
	lib = AssetLibrary.new()

	lib.add("res://a.png", "Asset1")
	lib.add("res://b.png", "Asset2")
	lib.add("res://c.png", "Asset3")

	var liste := lib.list()
	check_eq(liste[0]["id"], "a1", "Erstes Element ist a1")
	check_eq(liste[1]["id"], "a2", "Zweites Element ist a2")
	check_eq(liste[2]["id"], "a3", "Drittes Element ist a3")


func test_list_filter_kind() -> void:
	lib = AssetLibrary.new()

	lib.add("res://bild.png", "Bild")
	lib.add("res://musik.ogg", "Musik")
	lib.add("res://model.glb", "Modell")

	var liste_bilder := lib.list("bild")
	check_eq(liste_bilder.size(), 1, "Nur ein Bild")
	check_eq(liste_bilder[0]["name"], "Bild", "Name stimmt überein")

	var liste_modelle := lib.list("modell")
	check_eq(liste_modelle.size(), 1, "Nur ein Modell")


func test_find_case_insensitive() -> void:
	lib = AssetLibrary.new()

	lib.add("held_waffe.png", "Held Waffe")
	lib.add("burg_festung.png", "Burg Festung")

	var ergebnis := lib.find("WAF")
	check_eq(ergebnis.size(), 1, "Suche nach WAF findet ein Element")
	check_eq(ergebnis[0], "a1", "Richtiges Element gefunden")


func test_find_alle() -> void:
	lib = AssetLibrary.new()

	lib.add("held.png", "Held")
	lib.add("waffe.png", "Waffe")
	lib.add("burg.png", "Burg")

	var ergebnis := lib.find("")
	check_eq(ergebnis.size(), 3, "Alle Elemente bei leerer Suche")
