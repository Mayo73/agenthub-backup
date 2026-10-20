class_name FishAbilities
extends RefCounted
## Fähigkeiten des Fischs aus seinem Ausbau (FishBuild). Jede Stufe eines Bauteils wirkt spürbar.

## Höchsttempo in m/s: 8 + 2 je Stufe der Schwanzflosse.
static func max_speed(b: FishBuild) -> float:
	return 8.0 + 2.0 * b.level("schwanz")


## Beschleunigung in m/s²: 10 + 2,5 je Stufe der Schwanzflosse.
static func accel(b: FishBuild) -> float:
	return 10.0 + 2.5 * b.level("schwanz")


## Drehgeschwindigkeit in rad/s: 1,8 + 0,4 je Stufe der Brustflossen.
static func turn_rate(b: FishBuild) -> float:
	return 1.8 + 0.4 * b.level("flossen")


## Neigegeschwindigkeit in rad/s: 1,4 + 0,35 je Stufe der Brustflossen.
static func pitch_rate(b: FishBuild) -> float:
	return 1.4 + 0.35 * b.level("flossen")


## Bissschaden: 10 ohne Kiefer, +8 je Stufe.
static func bite_damage(b: FishBuild) -> float:
	return 10.0 + 8.0 * b.level("kiefer")


## Anteil des erlittenen Schadens, den die Stacheln abwehren: 0,15 je Stufe.
static func defense(b: FishBuild) -> float:
	return 0.15 * b.level("stacheln")


## Sichtweite im trüben Wasser in Metern: 20 + 22 je Stufe der Augen.
## Stufe 0: 20 m, Stufe 1: 42 m, Stufe 2: 64 m, Stufe 3: 86 m.
static func sight(b: FishBuild) -> float:
	return 20.0 + 22.0 * b.level("augen")


## Überträgt Tempo, Beschleunigung, Drehen und Neigen auf die Bewegung.
static func apply(b: FishBuild, motion: FishMotion) -> void:
	motion.max_speed = max_speed(b)
	motion.accel = accel(b)
	motion.turn_rate = turn_rate(b)
	motion.pitch_rate = pitch_rate(b)
