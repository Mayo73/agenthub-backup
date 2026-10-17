extends "res://tests/base_test.gd"

var cell: AiCell

func setup() -> void:
	cell = AiCell.new()

func teardown() -> void:
	cell.free()


func test_werte_der_art() -> void:
	cell.setup("schnapper", Vector2(50, 0))
	check_eq(cell.radius, 18.0, "radius")
	check_eq(cell.diet, Diet.FLEISCHFRESSER, "diet")
	check_eq(cell.health.max_hp, 40.0, "max_hp")
	check_eq(cell.motion.max_speed, 150.0, "max_speed")
	check_eq(cell.position, Vector2(50, 0), "position")
	check_eq(cell.damage, 15.0, "damage")


func test_jagen_und_schwimmen() -> void:
	cell.setup("schnapper", Vector2(50, 0))
	cell.think([{"position": Vector2(150, 0), "radius": 12.0, "diet": Diet.PFLANZENFRESSER}], null)
	check_eq(cell.wish, Vector2.RIGHT, "wish")
	check_eq(cell.brain.state, AiBrain.JAGEN, "state")
	cell.drive(0.1)
	check(cell.position.x > 50.0, "position moved right")


func test_info() -> void:
	cell.setup("blasenling", Vector2(5, 5))
	check_eq(cell.info()["radius"], 12.0, "info radius")
	check_eq(cell.info()["diet"], Diet.PFLANZENFRESSER, "info diet")


func test_maul() -> void:
	cell.setup("blasenling", Vector2.ZERO)
	check_eq(cell.mouth_point(), Vector2(12, 0), "mouth point")


func test_aussehen_der_art() -> void:
	var c := AiCell.new()
	c.setup("schnapper", Vector2.ZERO)
	check_eq(c.look.pattern, "streifen", "pattern")
	check_eq(c.look.stretch, 1.3, "stretch")
	check_eq(c.behavior, "jaeger", "behavior")
	c.free()


func test_stacheln() -> void:
	var c := AiCell.new()
	c.setup("stachelkugel", Vector2.ZERO)
	check_eq(c.spike_shapes().size(), 8, "spike count")
	var spikes := c.spike_shapes()
	check(spikes[0][1].is_equal_approx(Vector2(c.radius * 1.5, 0)), "first spike tip")
	c.free()


func test_zeit() -> void:
	var c := AiCell.new()
	c.setup("blasenling", Vector2.ZERO)
	c.drive(0.5)
	check_eq(c.time, 0.5, "time")
	c.free()


func test_blick_geradeaus() -> void:
	var c := AiCell.new()
	c.setup("blasenling", Vector2.ZERO)
	c.motion.heading = 0.0
	c.wish = Vector2(0, 1)
	check(c.pupil_dir().is_equal_approx(Vector2(0, 1)), "pupil dir geradeaus")
	c.free()


func test_blick_gedreht() -> void:
	var c := AiCell.new()
	c.setup("blasenling", Vector2.ZERO)
	c.motion.heading = PI / 2.0
	c.wish = Vector2(0, 1)
	check(c.pupil_dir().is_equal_approx(Vector2(1, 0)), "pupil dir gedreht")
	c.free()


func test_kein_ziel() -> void:
	var c := AiCell.new()
	c.setup("blasenling", Vector2.ZERO)
	check(c.pupil_dir() == Vector2.ZERO, "kein ziel")
	c.free()


func test_teile_der_art() -> void:
	var c := AiCell.new()
	c.setup("schnapper", Vector2.ZERO)
	check_eq(c.visible_parts().size(), 2, "teil count")
	check((c.visible_parts()[0]["pos"] as Vector2).is_equal_approx(Vector2(1.3, 0)), "erster teil pos")
	c.free()


func test_giftling_teile() -> void:
	var c := AiCell.new()
	c.setup("giftling", Vector2.ZERO)
	check_eq(c.visible_parts().size(), 3, "teil count")
	check_eq(c.visible_parts()[1]["id"], "gift", "zweiter teil id")
	c.free()


func test_kein_maulkreis() -> void:
	var content := FileAccess.get_file_as_string("res://scripts/ai_cell.gd")
	check(!content.contains("radius * 0.22"), "keine zeile mit radius * 0.22 mehr")


func test_farbe_bei_null() -> void:
	var c := AiCell.new()
	c.setup("schnapper", Vector2.ZERO)
	check(c.look.color.is_equal_approx(SpeciesCatalog.look_of("schnapper").color), "farbe bei null")
	c.free()


func test_farbvariante() -> void:
	var c := AiCell.new()
	c.setup("schnapper", Vector2(100, 0))
	var art := SpeciesCatalog.look_of("schnapper").color
	check(c.look.color.is_equal_approx(ColorVariants.vary(art, ColorVariants.seed_for(Vector2(100, 0)))), "farbvariante")
	check(!c.look.color.is_equal_approx(art), "farbe unterscheidet sich von art")
	check(c.color.is_equal_approx(SpeciesCatalog.data("schnapper")["color"]), "zelle color bleibt art farbe")
	c.free()


func test_gleiche_lage_gleiche_farbe() -> void:
	var a := AiCell.new()
	a.setup("blasenling", Vector2(250, 40))
	var b := AiCell.new()
	b.setup("blasenling", Vector2(250, 40))
	check(a.look.color.is_equal_approx(b.look.color), "gleiche lage gleiche farbe")
	a.free()
	b.free()


func test_giftling_hat_gift() -> void:
	var c := AiCell.new()
	c.setup("giftling", Vector2.ZERO)
	check(c.poison != null, "Giftling hat Giftwolken")
	c.free()


func test_schnapper_ohne_gift() -> void:
	var c := AiCell.new()
	c.setup("schnapper", Vector2.ZERO)
	check(c.poison == null, "Schnapper hat keine Giftwolken")
	c.free()


func test_zitterzelle_hat_organ() -> void:
	var c := AiCell.new()
	c.setup("zitterzelle", Vector2.ZERO)
	check(c.organ != null, "Zitterzelle hat Elektroorgan")
	c.free()


func test_blasenling_ohne_organ() -> void:
	var c := AiCell.new()
	c.setup("blasenling", Vector2.ZERO)
	check(c.organ == null, "Blasenling hat kein Elektroorgan")
	c.free()


func test_sichtweite() -> void:
	var a := AiCell.new()
	a.setup("blasenling", Vector2.ZERO)
	var b := AiCell.new()
	b.setup("riesenschlund", Vector2.ZERO)
	var c := AiCell.new()
	c.setup("schnapper", Vector2.ZERO)
	check_eq(a.brain.sight, 450.0, "blasenling (scheu) sieht 450")
	check_eq(b.brain.sight, 250.0, "riesenschlund (lauerer) sieht 250")
	check_eq(c.brain.sight, 350.0, "schnapper (jaeger) sieht Standard 350")
	a.free()
	b.free()
	c.free()


func test_lauerer() -> void:
	var a := AiCell.new()
	a.setup("riesenschlund", Vector2.ZERO)
	var b := AiCell.new()
	b.setup("schnapper", Vector2.ZERO)
	check(a.brain.lurker, "Riesenschlund hat lurker true")
	check(!b.brain.lurker, "Schnapper hat lurker false")
	a.free()
	b.free()


func test_herde() -> void:
	var a := AiCell.new()
	a.setup("weidezelle", Vector2.ZERO)
	var b := AiCell.new()
	b.setup("blasenling", Vector2.ZERO)
	check(a.brain.herd, "Weidezelle hat herd true")
	check(b.brain.herd == false, "Blasenling hat herd false")
	check(a.info()["herd"], "info herd wahr für Weidezelle")
	check(!b.info()["herd"], "info herd falsch für Blasenling")
	a.free()
	b.free()
