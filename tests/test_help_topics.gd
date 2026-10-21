extends "res://tests/base_test.gd"

var help: HelpTopics


func setup() -> void:
	help = HelpTopics.new()
	help.add("speichern", "Speichern", "Strg+S speichert das Projekt.", ["editor", "projekt"])
	help.add("export", "Exportieren", "Erstellt ein Windows-Spiel.", ["projekt"])
	help.add("auswahl", "Auswählen", "Klick wählt ein Objekt.", ["editor"])


func test_kontext() -> void:
	var result_projekt: Array[String] = help.for_context("projekt")
	check_eq(result_projekt, ["export", "speichern"], "for_context('projekt')")

	var result_editor: Array[String] = help.for_context("editor")
	check_eq(result_editor, ["auswahl", "speichern"], "for_context('editor')")

	var result_x: Array[String] = help.for_context("x")
	check_eq(result_x, [], "for_context('x')")


func test_suche() -> void:
	var result_windows: Array[String] = help.search("WINDOWS")
	check_eq(result_windows, ["export"], "search('WINDOWS')")

	var result_objekt: Array[String] = help.search("objekt")
	check_eq(result_objekt, ["auswahl"], "search('objekt')")

	var result_empty: Array[String] = help.search("")
	check_eq(result_empty, [], "search('')")


func test_zeilen() -> void:
	var lines_array: Array[String] = help.lines("projekt")
	check(lines_array.size() == 2, "lines('projekt') hat 2 Einträge")
	check_eq(lines_array[0], "Exportieren: Erstellt ein Windows-Spiel.", "lines('projekt')[0]")


func test_text() -> void:
	var text_export: String = help.text_of("export")
	check_eq(text_export, "Erstellt ein Windows-Spiel.", "text_of('export')")

	var text_nix: String = help.text_of("nix")
	check_eq(text_nix, "", "text_of('nix')")
