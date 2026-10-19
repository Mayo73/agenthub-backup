extends "res://tests/base_test.gd"

const FORBIDDEN: Array[String] = [
	"HTTPRequest",
	"HTTPClient",
	"StreamPeerTCP",
	"PacketPeerUDP",
	"WebSocketPeer",
	"TCPServer",
	"UDPServer",
	"ENetMultiplayerPeer",
	"OS.request_permission",
	"OS.shell_open"
]


func script_files() -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open("res://scripts")
	if dir == null:
		return files
	for name in dir.get_files():
		if name.ends_with(".gd"):
			files.append("res://scripts/%s" % name)
	return files


func findings() -> Array[String]:
	var result: Array[String] = []
	for pfad in script_files():
		var content := FileAccess.get_file_as_string(pfad)
		for wort in FORBIDDEN:
			if wort in content:
				result.append("%s: %s" % [pfad, wort])
	return result


func test_skripte_gefunden() -> void:
	var files := script_files()
	check("res://scripts/main.gd" in files, "main.gd wurde gefunden")
	check("res://scripts/ui_style.gd" in files, "ui_style.gd wurde gefunden")


func test_kein_netzwerk() -> void:
	var f := findings()
	check(f.is_empty(), ", ".join(f))


func test_keine_android_rechte() -> void:
	var cfg_path := "res://export_presets.cfg"
	if not FileAccess.file_exists(cfg_path):
		return
	var content := FileAccess.get_file_as_string(cfg_path)
	for restriction in ["permissions/internet=true", "permissions/access_fine_location=true", "permissions/access_coarse_location=true"]:
		check(not restriction in content, "Kein Android-Recht %s erlaubt" % restriction)
