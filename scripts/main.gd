extends Node2D
## Hauptszene der Zellenphase. Verdrahtet Spielerzelle, Nahrung, KI-Zellen, Kamera und HUD.
## Die Logik steckt in RefCounted-Klassen unter scripts/, hier nur Verdrahtung.

const MOUTH_REACH := 4.0

@onready var world: Node2D = $World
@onready var camera: Camera2D = $Camera

var player: PlayerCell
var progress := CellProgress.new()
var food := FoodField.new(7)
var food_view: FoodView
var hud: Hud
var spawner := EcoSpawner.new(11)
var ai_cells: Array[AiCell] = []


func _ready() -> void:
	Controls.setup()
	player = PlayerCell.new()
	player.name = "Player"
	world.add_child(player)
	camera.zoom = Vector2.ONE * CameraZoom.target_for_radius(player.radius)
	food.spawn_around(Vector2.ZERO, 60, 60.0, 900.0, 0.3)
	food_view = FoodView.new()
	food_view.name = "Food"
	food_view.field = food
	world.add_child(food_view)
	world.move_child(food_view, 0)
	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.show_progress(progress)


func _physics_process(_delta: float) -> void:
	feed_player()
	refill_food()
	spawn_ai()
	despawn_far_ai()
	think_ai()
	feed_ai()


## Frisst alles, was das Maul der Spielerzelle berührt und zur Ernährung passt.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH, player.diet):
		if progress.eat(item.value):
			player.set_stage(progress.stage)


## Entfernt weit entfernte Nahrung und streut neue um den Spieler, wenn sie knapp wird.
func refill_food() -> void:
	food.remove_far(player.position, 1400.0)
	if food.items.size() < 40:
		food.spawn_around(player.position, 20, 500.0, 1200.0, 0.3)


func _process(delta: float) -> void:
	camera.position = player.position
	var zoom := CameraZoom.smooth(camera.zoom.x, CameraZoom.target_for_radius(player.radius), delta)
	camera.zoom = Vector2(zoom, zoom)
	hud.show_progress(progress)


## Füllt die KI-Zellen auf EcoSpawner.TARGET_COUNT auf.
func spawn_ai() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	for i in EcoSpawner.missing(ai_cells.size()):
		var cell := AiCell.new()
		cell.setup(spawner.pick_species(progress.stage), spawner.spawn_position(player.position, spread))
		world.add_child(cell)
		ai_cells.append(cell)


func remove_ai(cell: AiCell) -> void:
	ai_cells.erase(cell)
	world.remove_child(cell)
	cell.queue_free()


func despawn_far_ai() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	for cell in ai_cells.duplicate():
		if EcoSpawner.is_too_far(player.position, cell.position, spread):
			remove_ai(cell)


## Jede KI-Zelle entscheidet anhand aller Zellen (Spieler eingeschlossen) und der nächsten Nahrung.
func think_ai() -> void:
	var infos: Array = [{"position": player.position, "radius": player.radius, "diet": player.diet}]
	for cell in ai_cells:
		infos.append(cell.info())
	for cell in ai_cells:
		var kind := Diet.FLEISCH if cell.diet == Diet.FLEISCHFRESSER else Diet.PFLANZE
		var item := food.nearest(cell.position, kind, cell.brain.sight)
		cell.think(infos, item.position if item != null else null)


func feed_ai() -> void:
	for cell in ai_cells:
		food.take_at(cell.mouth_point(), MOUTH_REACH, cell.diet)
