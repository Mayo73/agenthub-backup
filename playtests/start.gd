extends Playtest
## Engine starten, Titel und Version prüfen.


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Hub Engine startet und zeigt Titel und Version"


func run() -> void:
	await wait(0.5)
	check(scene.title_label.text.begins_with("Hub Engine"), "Titel sichtbar")
	shot("start")
