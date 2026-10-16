class_name ElectricOrgan
extends RefCounted
## Elektrische Abwehr: entlädt sich, wenn ein Gegner nah genug ist, und lädt dann nach.

const DAMAGE := 18.0
const COOLDOWN := 1.5
## Reichweite in Zellradien, von der Zellmitte gemessen
const RANGE := 1.6
## Wie lange der Blitz nach einer Entladung sichtbar bleibt
const FLASH_TIME := 0.2

var charge_time := 0.0
var flash := 0.0


func tick(delta: float) -> void:
	charge_time = maxf(0.0, charge_time - delta)
	flash = maxf(0.0, flash - delta)


func is_ready() -> bool:
	return charge_time <= 0.0


func fire() -> void:
	charge_time = COOLDOWN
	flash = FLASH_TIME


static func in_range(center: Vector2, radius: float, target_pos: Vector2, target_radius: float) -> bool:
	return center.distance_to(target_pos) <= radius * RANGE + target_radius
