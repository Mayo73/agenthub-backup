class_name Wind
extends RefCounted
## Vereinfachtes Modell für Luftwiderstand und Wind auf Projektile.
## Beschleunigung durch Luft: a = -drag * (v - wind)
## Lineare Abhängigkeit von der Relativgeschwindigkeit (bewusst vereinfacht,
## kein quadratischer Luftwiderstand wie in der realen Physik).
## drag pro Sekunde, 0 bedeutet kein Luftwiderstand.
## Wind-Einheiten sind Einheiten/s.

var drag: float = 0.0
var wind: Vector3 = Vector3.ZERO


func _init(drag_value: float = 0.0, wind_value: Vector3 = Vector3.ZERO) -> void:
	drag = drag_value
	wind = wind_value


func acceleration(velocity: Vector3) -> Vector3:
	return -drag * (velocity - wind)


func acceleration_2d(velocity: Vector2) -> Vector2:
	return -drag * (velocity - Vector2(wind.x, wind.y))


func step(velocity: Vector3, dt: float) -> Vector3:
	return velocity + acceleration(velocity) * dt


func terminal_velocity(gravity: float) -> float:
	if drag <= 0.0:
		return INF
	return gravity / drag


func to_dict() -> Dictionary:
	return {"drag": drag, "wind": [wind.x, wind.y, wind.z]}


static func from_dict(d: Dictionary) -> Wind:
	var w := Vector3.ZERO
	if d.has("wind"):
		var arr := d["wind"] as Array
		w = Vector3(
			arr[0] if arr.size() > 0 else 0.0,
			arr[1] if arr.size() > 1 else 0.0,
			arr[2] if arr.size() > 2 else 0.0
		)
	return Wind.new(
		d.get("drag", 0.0),
		w
	)
