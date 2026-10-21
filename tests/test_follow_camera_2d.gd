extends "res://tests/base_test.gd"

var camera: FollowCamera2D


func setup() -> void:
	camera = FollowCamera2D.new()
	## default smoothing=8.0 wird beibehalten
	## Test_Folgen erwartet smoothing=0 für sofortige Bewegung (wird im Test gesetzt)


func test_totzone() -> void:
	## position bleibt Vector2.ZERO, da target innerhalb der Totzone liegt
	var initial_pos: Vector2 = camera.position
	var result: Vector2 = camera.update(Vector2(1.0, 0.5), 0.1)
	check_eq(result, initial_pos, "position bleibt unverändert wenn target in Totzone")


func test_folgen() -> void:
	## position.x wird 3.0 (Ziel am Rand der Totzone rechts)
	camera.smoothing = 0.0
	var result: Vector2 = camera.update(Vector2(5.0, 0.0), 0.1)
	check_eq(result.x, 3.0, "position folgt target am Rand der Totzone")


func test_grenzen() -> void:
	## bounds setzen, position.x wird auf 10.0 begrenzt (halbe Bildbreite von rechts)
	camera.smoothing = 0.0
	camera.bounds = Rect2(0.0, 0.0, 100.0, 20.0)
	var result: Vector2 = camera.update(Vector2(-50.0, 0.0), 0.1)
	check_eq(result.x, 10.0, "position wird an linke Grenze geklemmt")


func test_kleines_level() -> void:
	## bounds kleiner als view_size → Mitte von bounds wird zurückgegeben
	camera.bounds = Rect2(0.0, 0.0, 10.0, 5.0)
	var result: Vector2 = camera.clamp_to_bounds(Vector2(40.0, 40.0))
	check_eq(result, Vector2(5.0, 2.5), "bei kleinem Level wird Mitte von bounds verwendet")


func test_weich() -> void:
	## smoothing = 5.0, nach update sollte position ungefähr halbwegs zu Ziel sein
	camera.smoothing = 5.0
	camera.bounds = Rect2()
	camera.position = Vector2.ZERO
	var result: Vector2 = camera.update(Vector2(12.0, 0.0), 0.1)
	## Mit smoothing=5.0 und dt=0.1 ist factor=clampf(0.5,0,1)=0.5
	## lerp von 0 zu 10 mit 0.5 ergibt 5.0
	var diff: float = abs(result.x - 5.0)
	check(diff < 0.5, "position ungefähr halbwegs zu Ziel bei weicher Bewegung")


func test_sichtbares_rechteck() -> void:
	## visible_rect sollte Rechteck mit Mitte position und Größe view_size zurückgeben
	camera.position = Vector2(10.0, 5.0)
	var rect: Rect2 = camera.visible_rect()
	check_eq(rect.position.x, 0.0, "position vom sichtbaren Rechteck korrekt")
	check_eq(rect.size, camera.view_size, "größe des sichtbaren Rechtecks korrekt")


func test_to_dict() -> void:
	## to_dict sollte alle Eigenschaften serialisieren
	camera.position = Vector2(3.0, 4.0)
	camera.bounds = Rect2(-10.0, -5.0, 100.0, 50.0)
	var d: Dictionary = camera.to_dict()
	check_eq(d["position"], [3.0, 4.0], "position in Dictionary")
	check_eq(d["view_size"], [20.0, 11.25], "view_size in Dictionary")
	check_eq(d["dead_zone"], [2.0, 1.5], "dead_zone in Dictionary")
	check_eq(d["smoothing"], 8.0, "smoothing in Dictionary")
	check_eq(d["bounds"].get("position_x"), -10.0, "bounds position_x in Dictionary")
	check_eq(d["bounds"].get("size_x"), 100.0, "bounds size_x in Dictionary")


func test_from_dict() -> void:
	## from_dict sollte ein FollowCamera2D aus einem Dictionary erstellen
	var d: Dictionary = {
		"position": Vector2(7.0, -3.0),
		"view_size": Vector2(30.0, 15.0),
		"dead_zone": Vector2(3.0, 2.0),
		"smoothing": 12.0,
		"bounds": {
			"position_x": -5.0,
			"position_y": -5.0,
			"size_x": 200.0,
			"size_y": 100.0
		}
	}
	var cam: FollowCamera2D = FollowCamera2D.from_dict(d)
	check_eq(cam.position, Vector2(7.0, -3.0), "position aus Dictionary")
	check_eq(cam.view_size, Vector2(30.0, 15.0), "view_size aus Dictionary")
	check_eq(cam.dead_zone, Vector2(3.0, 2.0), "dead_zone aus Dictionary")
	check_eq(cam.smoothing, 12.0, "smoothing aus Dictionary")
	## bounds werden aus den vier Feldern korrekt gesetzt
	check_eq(cam.bounds.position.x, -5.0, "bounds position_x aus Dictionary")
	check_eq(cam.bounds.size.x, 200.0, "bounds size_x aus Dictionary")


func test_schmal_in_einer_achse() -> void:
	## Level breiter als das Bild, aber niedriger: x wird begrenzt, y in die Mitte
	camera.bounds = Rect2(0.0, 0.0, 100.0, 5.0)
	var result: Vector2 = camera.clamp_to_bounds(Vector2(-40.0, 40.0))
	check_eq(result, Vector2(10.0, 2.5), "x an der Grenze, y in der Mitte")


func test_speichern_json() -> void:
	camera.position = Vector2(3.0, 4.0)
	camera.bounds = Rect2(-10.0, -5.0, 100.0, 50.0)
	var text := JSON.stringify(camera.to_dict())
	var cam: FollowCamera2D = FollowCamera2D.from_dict(JSON.parse_string(text))
	check_eq(cam.position, Vector2(3.0, 4.0), "position aus JSON")
	check_eq(cam.view_size, camera.view_size, "view_size aus JSON")
	check_eq(cam.bounds.size.x, 100.0, "bounds aus JSON")
