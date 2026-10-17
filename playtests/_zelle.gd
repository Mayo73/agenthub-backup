extends Playtest
## Gemeinsame Hilfen der Zellenphase-Spieltests: Partie starten, ohne den Spielstand des Nutzers
## anzufassen, und die Spielerzelle über die echten Eingabeaktionen (WASD) steuern.

const MAIN_SCENE := "res://scenes/main.tscn"
const TEST_SAVE := "user://spieltest_spielstand.json"

## Ziel in Weltkoordinaten, auf das die Zelle zuschwimmt (null: nicht steuern).
var target: Variant = null
var _sent := {}


func _init() -> void:
	scene_path = MAIN_SCENE


## Neue Partie als Pflanzen- oder Fleischfresser, ohne in den Spielstand des Nutzers zu schreiben.
func start_game(diet: String = Diet.PFLANZENFRESSER) -> void:
	scene.save_path = TEST_SAVE
	scene.start_new(diet)
	scene.autosave = false
	await wait(0.5)


## Startet eine Vorführszene (DemoScenes), ebenfalls ohne zu speichern.
func start_demo(scene_name: String) -> void:
	scene.save_path = TEST_SAVE
	scene.start_scene(scene_name)
	scene.autosave = false
	await wait(0.2)


## Nächste Nahrung, die zur Ernährung der Spielerzelle passt (oder null).
func nearest_food() -> FoodItem:
	var kind := Diet.PFLANZE if scene.player.diet == Diet.PFLANZENFRESSER else Diet.FLEISCH
	return scene.food.nearest(scene.player.position, kind)


## Nicht mehr steuern und alle Richtungstasten loslassen.
func stop_steering() -> void:
	target = null
	for action in _sent.keys():
		release(action)
	_sent.clear()


func _physics_process(_delta: float) -> void:
	if target == null or scene == null or not is_instance_valid(scene):
		return
	var offset: Vector2 = target - scene.player.position
	var dir := offset.normalized() if offset.length() > 4.0 else Vector2.ZERO
	_set_action("rechts", maxf(dir.x, 0.0))
	_set_action("links", maxf(-dir.x, 0.0))
	_set_action("runter", maxf(dir.y, 0.0))
	_set_action("hoch", maxf(-dir.y, 0.0))


func _set_action(action: String, strength: float) -> void:
	var old: float = _sent.get(action, 0.0)
	if absf(old - strength) < 0.05:
		return
	_sent[action] = strength
	if strength > 0.0:
		press(action, strength)
	else:
		release(action)
