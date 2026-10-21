extends "res://tests/base_test.gd"

var profile: ExportProfile
var allowed_root: String


func setup() -> void:
	profile = ExportProfile.new()
	allowed_root = "C:/Spiele"


func teardown() -> void:
	profile = null


func test_gueltig() -> void:
	profile.game_name = "Demo"
	profile.output_path = "C:\\Spiele\\out\\demo.EXE"
	profile.icon_path = "icon.ico"
	var errors: Array[String] = profile.validate(allowed_root)
	check_eq(errors, [], "gueltiges Profil sollte keine Fehler haben")


func test_leer() -> void:
	profile = ExportProfile.new()
	var errors: Array[String] = profile.validate(allowed_root)
	check_eq(errors, ["name_fehlt", "pfad_fehlt"], "neues Profil sollte name_fehlt und pfad_fehlt haben")


func test_endung() -> void:
	profile.game_name = "Test"
	profile.output_path = "C:/Spiele/out/demo.zip"
	var errors: Array[String] = profile.validate(allowed_root)
	check_eq(errors, ["keine_exe"], ".zip Datei sollte keine_exe Fehler geben")


func test_ort() -> void:
	# externer Pfad
	profile.game_name = "Test"
	profile.output_path = "C:/Anders/demo.exe"
	var errors: Array[String] = profile.validate(allowed_root)
	check_eq(errors, ["pfad_nicht_erlaubt"], "externer Pfad sollte pfad_nicht_erlaubt geben")

	# parent Verweis
	profile.game_name = "Test"
	profile.output_path = "C:/Spiele/../demo.exe"
	errors = profile.validate(allowed_root)
	check_eq(errors, ["pfad_nicht_erlaubt"], "../ im Pfad sollte pfad_nicht_erlaubt geben")


func test_icon() -> void:
	profile.game_name = "Test"
	profile.output_path = "C:/Spiele/out/demo.exe"
	profile.icon_path = "icon.png"
	var errors: Array[String] = profile.validate(allowed_root)
	check_eq(errors, ["icon_kein_ico"], ".png Icon sollte icon_kein_ico geben")
