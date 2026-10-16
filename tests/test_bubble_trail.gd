extends "res://tests/base_test.gd"

var t: BubbleTrail


func setup() -> void:
	t = BubbleTrail.new()


func test_ausstossen() -> void:
	t.emit(Vector2(5, 5), 2.0)
	check_eq(t.bubbles.size(), 1, "bubbles.size() ist 1")
	check_eq(t.bubbles[0]["size"], 2.0, "t.bubbles[0][\"size\"] ist 2.0")


func test_aufsteigen() -> void:
	t.emit(Vector2(0, 100), 2.0)
	t.tick(0.5)
	check((t.bubbles[0]["pos"] as Vector2).is_equal_approx(Vector2(0, 91)), "Bläschen ist aufgestiegen")
	check_eq(t.bubbles[0]["age"], 0.5, "age ist 0.5")


func test_verschwinden() -> void:
	t.emit(Vector2.ZERO, 2.0)
	t.tick(1.3)
	check_eq(t.bubbles.size(), 0, "bubbles.size() ist 0 nach Ablauf der Lebensdauer")


func test_hoechstzahl() -> void:
	for i in range(45):
		t.emit(Vector2.ZERO, 1.0)
	check_eq(t.bubbles.size(), 40, "höchstens 40 Bläschen")


func test_deckkraft() -> void:
	check_eq(BubbleTrail.alpha(0.0), 0.5, "alpha(0.0) ist 0.5")
	check_eq(BubbleTrail.alpha(0.6), 0.25, "alpha(0.6) ist 0.25")
	check_eq(BubbleTrail.alpha(5.0), 0.0, "alpha(5.0) ist 0.0")


func test_view() -> void:
	var v := BubbleView.new()
	v.trail = t
	check(v.trail == t, "v.trail == t")
	v.free()
