extends Playtest
## App starten, Prototyp-Hinweis und Reiter prüfen, durch die Reiter tippen.


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "App startet mit Prototyp-Hinweis, Reiter wechseln den Bildschirm"


func run() -> void:
	await wait(0.5)
	check(scene.banner.visible and scene.banner.text.contains("PROTOTYP"), "Prototyp-Hinweis sichtbar")
	shot("entdecken")
	for screen_name in ["matches", "profil", "entdecken"]:
		scene.tab_buttons[screen_name].pressed.emit()
		await wait(0.2)
		check(scene.current_screen == screen_name, "Reiter %s zeigt seinen Bildschirm" % screen_name)
