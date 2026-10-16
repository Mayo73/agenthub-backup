extends "res://tests/base_test.gd"
## Test für die Größenfortschritts-Mechanik: fünf Abschnitte, Zoom-Verhalten, Begegnungen und Gefahren/Beute-Umkehr.


func test_fuenf_abschnitte() -> void:
	var p := CellProgress.new()
	var stages: Array[int] = [0]
	for i in range(200):
		p.eat(1)
		if not stages.has(p.stage):
			stages.append(p.stage)
	check_eq(stages, [0, 1, 2, 3, 4], "alle fünf Abschnitte erreicht")


func test_radius_waechst() -> void:
	for s in range(1, 5):
		check(CellProgress.radius_for_stage(s) > CellProgress.radius_for_stage(s - 1),
			"Radius wächst von Stufe %d zu %d" % [s - 1, s])


func test_zoom_sinkt() -> void:
	for s in range(1, 5):
		var r_prev := CellProgress.radius_for_stage(s - 1)
		var r_curr := CellProgress.radius_for_stage(s)
		check(CameraZoom.target_for_radius(r_curr) < CameraZoom.target_for_radius(r_prev),
			"Zoom sinkt von Stufe %d zu %d" % [s - 1, s])


func test_begegnungen_je_abschnitt() -> void:
	for s in range(5):
		var near := SpeciesCatalog.ids_near_stage(s)
		check(near.size() >= 2, "mindestens 2 Begegnungen in Stufe %d" % s)


func test_aus_gefahr_wird_beute() -> void:
	var schnapper_radius := SpeciesCatalog.radius_of("schnapper")
	var diet: String = SpeciesCatalog.data("schnapper").get("diet", "")

	# In Stufe 0 ist Schnapper eine Gefahr
	check(AiBrain.is_threat(CellProgress.radius_for_stage(0), schnapper_radius, diet),
		"Schnapper ist Gefahr in Stufe 0")

	# In Stufe 3 ist Schnapper keine Gefahr mehr
	check(not AiBrain.is_threat(CellProgress.radius_for_stage(3), schnapper_radius, diet),
		"Schnapper ist keine Gefahr in Stufe 3")

	# In Stufe 3 kann ein Fleischfresser den Schnapper fressen
	check(AiBrain.is_prey(CellProgress.radius_for_stage(3), Diet.FLEISCHFRESSER, schnapper_radius),
		"Schnapper ist Beute für Fleischfresser in Stufe 3")
