extends RefCounted
class_name FireControl

## Schussrate (Schüsse pro Sekunde)
var rate: float = 4.0
## Magazingröße (Geschosse im Magazin)
var magazine_size: int = 6
## Nachladezeit in Sekunden
var reload_time: float = 1.5
## Aktuelle Munition im Magazin
var ammo: int = 6

var _cooldown: float = 0.0
var _reload_left: float = 0.0

func _init(rate_value: float = 4.0, magazine: int = 6, reload_seconds: float = 1.5) -> void:
	rate = rate_value
	magazine_size = magazine
	reload_time = reload_seconds
	ammo = magazine


## Gibt true zurück, wenn gerade nachgeladen wird
func is_reloading() -> bool:
	return _reload_left > 0.0


## Gibt true zurück, wenn gefeuert werden darf
func can_fire() -> bool:
	return not is_reloading() and ammo > 0 and _cooldown <= 0.0


## Versucht zu feuern. True wenn erfolgreich, false sonst.
func fire() -> bool:
	if can_fire():
		ammo -= 1
		_cooldown = 1.0 / rate
		if ammo == 0:
			reload()
		return true
	return false


## Startet das Nachladen. True wenn gestartet, false sonst.
func reload() -> bool:
	if is_reloading() or ammo >= magazine_size:
		return false
	_reload_left = reload_time
	return true


## Fortschritt simulieren
func step(dt: float) -> void:
	_cooldown = maxf(_cooldown - dt, 0.0)
	if _reload_left > 0.0:
		_reload_left -= dt
		if _reload_left <= 0.0:
			_reload_left = 0.0
			ammo = magazine_size


## Hilfsfunktion für Tests: simuliert n Schritte und zählt Schüsse
func shots_in(seconds: float, hz: int = 120) -> int:
	var steps: int = roundi(seconds * hz)
	var successful_shots: int = 0
	for i in range(steps):
		if fire():
			successful_shots += 1
		step(1.0 / hz)
	return successful_shots
