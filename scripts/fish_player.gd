class_name FishPlayer
extends Node3D
## Spielerfisch: bewegt sich mit FishMotion und zeigt sich als FishModel.

var motion := FishMotion.new()
var build := FishBuild.new()
var model: FishModel
## Größe (1 = Anfang); skaliert das Modell.
var size := 1.0


func _init() -> void:
	model = FishModel.new()
	model.name = "Model"
	add_child(model)
	model.rebuild(build)
	sync()


## Übernimmt einen neuen Ausbau (Übergang, Entwicklung) und baut das Aussehen neu.
func set_build(b: FishBuild) -> void:
	build = b
	model.rebuild(b)


func set_size(s: float) -> void:
	size = s
	model.scale = Vector3.ONE * s


## Ein Schritt mit dem Schwimmbefehl aus FishInput: command = Vector3(thrust, turn, climb).
func drive(command: Vector3, delta: float) -> void:
	motion.step(command.x, command.y, command.z, delta)
	sync()
	model.animate(delta, motion.speed())


## Überträgt Lage und Ausrichtung aus FishMotion auf den Knoten.
func sync() -> void:
	position = motion.position
	rotation = Vector3(motion.pitch, motion.yaw, 0.0)


## Maulspitze in Weltkoordinaten (vorn am Körper), für Fressen und Beißen.
func mouth_point() -> Vector3:
	return motion.position + motion.forward() * 0.8 * size
