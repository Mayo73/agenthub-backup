extends "res://tests/base_test.gd"

var h: TutorialHints

func setup() -> void:
	h = TutorialHints.new()


func test_einmal() -> void:
	check_eq(h.trigger("bewegen"), TutorialHints.TEXTS["bewegen"], "erster Aufruf gibt Text")
	check_eq(h.trigger("bewegen"), "", "zweiter Aufruf gibt leer")


func test_unbekannt() -> void:
	check_eq(h.trigger("gibtsnicht"), "", "unbekannte ID ergibt leer")
	check_eq(h.shown.size(), 0, "nichts wurde gemerkt")


func test_speichern() -> void:
	h.trigger("fressen")
	h.trigger("editor")
	var k := TutorialHints.from_array(h.to_array())
	check_eq(k.shown.size(), 2, "beide Hinweise wurden wiederhergestellt")
	check_eq(k.trigger("fressen"), "", "bereits gezeigter Hinweis ergibt leer")
	check(k.trigger("gefahr") != "", "neuer Hinweis wird angezeigt")


func test_kaputte_daten() -> void:
	var result := TutorialHints.from_array(["bewegen", "bewegen", "quatsch", 5])
	check_eq(result.shown.size(), 1, "nur gültiger Hinweis gespeichert")


func test_alle_texte() -> void:
	check_eq(TutorialHints.TEXTS.size(), 5, "fünf Hinweise definiert")
