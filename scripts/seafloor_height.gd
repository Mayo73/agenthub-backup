class_name SeafloorHeight
extends RefCounted
## Höhenprofil des Meeresbodens aus Rauschen. Dieselbe Stelle hat immer dieselbe Höhe.

## Höchste Erhebung über dem tiefsten Boden
const RELIEF := 10.0
## Zusätzliche Tiefe in Tiefseegebieten
const TRENCH := 25.0

var noise: FastNoiseLite
var trench_noise: FastNoiseLite


func _init(seed_value: int = 7) -> void:
	noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.012
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH

	trench_noise = FastNoiseLite.new()
	trench_noise.seed = seed_value + 1
	trench_noise.frequency = 0.004


## y des Bodens (Weltkoordinaten, y zeigt nach oben)
func height_at(x: float, z: float) -> float:
	var basis := -FishWorld.DEPTH + (noise.get_noise_2d(x, z) * 0.5 + 0.5) * RELIEF

	var t := trench_noise.get_noise_2d(x, z)
	if t > 0.35:
		basis -= TRENCH * clampf((t - 0.35) / 0.3, 0.0, 1.0)

	return basis


## Ist die Stelle Teil einer Tiefseerinne?
func is_trench(x: float, z: float) -> bool:
	return trench_noise.get_noise_2d(x, z) > 0.35
