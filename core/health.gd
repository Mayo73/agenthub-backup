extends RefCounted
class_name Health

## Maximale Lebenspunkte
var max_hp: float = 100.0
## Aktuelle Lebenspunkte
var hp: float = 100.0
## Schutzzeit in Sekunden nach einem Treffer
var invulnerable_time: float = 0.0
## Verbleibende Schutzzeit (intern)
var _protect: float = 0.0


func _init(max_value: float = 100.0) -> void:
	max_hp = max_value
	hp = max_value


func is_dead() -> bool:
	return hp <= 0.0


func damage(amount: float) -> float:
	if amount <= 0.0 or is_dead() or _protect > 0.0:
		return 0.0

	var original_hp: float = hp
	hp = maxf(hp - amount, 0.0)
	_protect = invulnerable_time
	return original_hp - hp


func heal(amount: float) -> float:
	if is_dead() or amount <= 0.0:
		return 0.0

	var original_hp: float = hp
	hp = minf(hp + amount, max_hp)
	return hp - original_hp


func step(dt: float) -> void:
	_protect = maxf(_protect - dt, 0.0)


func ratio() -> float:
	if max_hp <= 0.0:
		return 0.0
	return hp / max_hp


func to_dict() -> Dictionary:
	return {
		"max_hp": max_hp,
		"hp": hp,
		"invulnerable_time": invulnerable_time
	}


static func from_dict(d: Dictionary) -> Health:
	var result: Health = Health.new()
	result.max_hp = d.get("max_hp", 100.0)
	result.hp = d.get("hp", 100.0)
	result.invulnerable_time = d.get("invulnerable_time", 0.0)
	return result
