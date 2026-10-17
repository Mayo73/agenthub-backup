class_name AiFish
extends Node3D
## KI-Fisch der Fischphase: Werte aus FishSpecies, Aussehen aus FishModel, Verhalten aus FishBrain.

var species_id := ""
var motion := FishMotion.new()
var health := CellHealth.new()
var size := 1.0
var model: FishModel


func _init() -> void:
	model = FishModel.new()
	model.name = "Model"
	add_child(model)


## Übernimmt die Werte der Art und setzt den Fisch an pos.
func setup(id: String, pos: Vector3) -> void:
	species_id = id
	var d := FishSpecies.data(id)
	size = float(d.get("size", 1.0))
	motion.max_speed = float(d.get("speed", 5.0))
	motion.position = FishWorld.clamp_to_water(pos)
	health = CellHealth.new(float(d.get("hp", 30.0)))
	var b := FishBuild.new()
	b.color = d.get("color", b.color)
	if FishSpecies.is_predator(id):
		b.levels["kiefer"] = 2
	model.rebuild(b)
	model.scale = Vector3.ONE * size
	sync()


## Körperradius des Fisches in Metern.
func radius() -> float:
	return FishSpecies.radius(species_id)


## Position des Mauls des Fisches in Weltkoordinaten.
func mouth_point() -> Vector3:
	return motion.position + motion.forward() * 0.8 * size


## Synchronisiert Node-Position und -Rotation mit der Bewegungslogik.
func sync() -> void:
	position = motion.position
	rotation = Vector3(motion.pitch, motion.yaw, 0.0)


## Denkt und bewegt den Fisch einen Zeitschritt lang.
func think(delta: float, player_pos: Vector3, player_size: float, flock_center: Variant) -> void:
	var d := FishSpecies.data(species_id)
	var behavior: String = d.get("behavior", "schwarm")
	var sight: float = float(d.get("sight", 10.0))
	var dir := FishBrain.decide(behavior, motion.position, size, sight, player_pos, player_size, flock_center)
	var c := FishBrain.steer(motion, dir)
	motion.step(c.x, c.y, c.z, delta)
	health.tick(delta)
	sync()
	model.animate(delta, motion.speed())
