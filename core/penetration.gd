class_name Penetration
extends RefCounted

## Statische Funktionen für Penetrationsberechnungen beim Durchschlagen von Material.


## Berechnet die Austrittsgeschwindigkeit nach dem Durchschlagen eines Materials.
## Die Geschwindigkeit reduziert sich um thickness * resistance.
static func exit_speed(speed: float, thickness: float, resistance: float) -> float:
	return maxf(speed - thickness * resistance, 0.0)


## Prüft, ob ein Projektil das Material durchdringen kann.
static func passes(speed: float, thickness: float, resistance: float) -> bool:
	return exit_speed(speed, thickness, resistance) > 0.0


## Berechnet den Schadensfaktor basierend auf Ein- und Austrittsgeschwindigkeit.
static func damage_factor(entry_speed: float, exit_speed_value: float) -> float:
	if entry_speed <= 0.0:
		return 0.0
	return clampf(exit_speed_value / entry_speed, 0.0, 1.0)
