extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Entwicklungsmenü mit bezahlbaren Verbesserungen ist aktiv.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: bezahlbare Verbesserungen sind aktiv und wirken"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# Genug DNA für Verbesserungen bereitstellen
	scene.progress.dna = 40

	# Entwicklungsmenü öffnen
	await tap("entwickeln")
	check(scene.evolve.visible, "E öffnet das Entwicklungsmenü")

	# Prüfen, dass der Knopf "schwanz" nicht deaktiviert ist (DNA reicht)
	check(not scene.evolve.buttons["schwanz"].disabled, "Schwanz-Knopf ist bei 40 DNA aktiv")

	# Erstes Bild: bezahlbarer Knopf
	shot("bezahlbar")

	# Knopf "schwanz" drücken → level um 1 höher, dna um COSTS[0] = 10 kleiner
	scene.evolve.buttons["schwanz"].pressed.emit()
	check(scene.player.build.level("schwanz") == 1, "Schwanz nach Kauf auf Stufe 1")
	check(scene.progress.dna == 30, "DNA nach Kauf: 40 - 10 = 30")

	# Zweites Bild: nach dem ersten Kauf
	shot("nach_kauf")

	# Weiter kaufen, bis die DNA nicht mehr reicht
	# Stage 2 kostet 20 DNA, wir haben 30 → kann noch gekauft werden
	scene.evolve.buttons["schwanz"].pressed.emit()
	check(scene.player.build.level("schwanz") == 2, "Schwanz nach zweitem Kauf auf Stufe 2")
	check(scene.progress.dna == 10, "DNA nach zweitem Kauf: 30 - 20 = 10")

	# Drittes Bild: vor letztem Kauf
	shot("fast_alle")

	# Stage 3 kostet 35 DNA, wir haben nur noch 10 → kann nicht gekauft werden
	scene.evolve.buttons["schwanz"].pressed.emit()
	check(scene.player.build.level("schwanz") == 2, "Schwanz bleibt bei Stufe 2 (nicht genug DNA)")
	check(scene.progress.dna == 10, "DNA unverändert: 10")
	check(scene.evolve.buttons["schwanz"].disabled, "Schwanz-Knopf ist deaktiviert (nicht genug DNA für nächste Stufe)")

	# Entwicklungsmenü schließen
	await tap("entwickeln")
	check(not scene.evolve.visible, "E schließt das Menü erneut")
