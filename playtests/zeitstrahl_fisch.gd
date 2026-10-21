extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Zeitstrahl mit Taste T und im Pausemenü öffnen, neue Größe speichern.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: Zeitstrahl mit T und im Pausemenü"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# Zeitstrahl über den Button öffnen (Taste T ist auch möglich, aber Button ist direkter)
	await tap("zeitstrahl")
	check(scene.timeline_view.visible, "Zeitstrahl nach Tap auf Button sichtbar")
	shot("zeitstrahl")

	await tap("zeitstrahl")
	check(not scene.timeline_view.visible, "Zeitstrahl nach zweitem Tap unsichtbar")

	# Nahrung geben, bis der Fisch eine Größe wächst: direkt über eat_value() wie beim Fressen
	while not scene.progress.is_final_stage():
		scene.eat_value(20) # GROWTH_NEEDED beginnt mit 20, das reicht zum Wachsen
	await wait(0.5)

	# Letzter Eintrag muss ein FISH_SIZE-Eintrag sein
	check(scene.timeline.size() > 0, "Zeitstrahl hat Einträge")
	var last_entry: Dictionary = scene.timeline.last()
	check(last_entry.get("kind") == EvolutionTimeline.FISH_SIZE,
		"Letzter Zeitstrahl-Eintrag ist Fischgröße ('%s' statt '%s')" % [last_entry.get("kind"), EvolutionTimeline.FISH_SIZE])

	await tap("pause")
	scene.pause_menu.timeline_button.pressed.emit()
	await wait(0.3)
	check(scene.timeline_view.visible, "Zeitstrahl nach Öffnen aus Pause-Menü sichtbar")
	check(not scene.paused, "Spiel läuft nach Zeitstrahl-Öffnung weiter (nicht paused)")
	shot("aus_pause")
	measure("eintraege", scene.timeline.size())
