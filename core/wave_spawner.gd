class_name WaveSpawner
extends RefCounted
## Zeitplan für Gegnerwellen. Liefert nur, was wann erscheinen soll;
## das Erzeugen der Nodes übernimmt das Spiel.

var waves: Array[Dictionary] = []
var wave_index := 0
var _spawned := 0
var _timer := 0.0


func add_wave(kind: String, count: int, interval: float, delay: float = 0.0) -> CommandResult:
	if kind.is_empty() or count <= 0 or interval < 0.0:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Ungültige Welle")
	waves.append({"kind": kind, "count": count, "interval": interval, "delay": delay})
	return CommandResult.success({"index": waves.size() - 1})


func start() -> void:
	wave_index = 0
	_spawned = 0
	_timer = 0.0
	if not waves.is_empty():
		var delay: float = waves[0]["delay"]
		_timer = delay


func finished() -> bool:
	return wave_index >= waves.size()


func step(dt: float) -> Array[String]:
	var result: Array[String] = []
	_timer -= dt
	while not finished() and _timer <= 0.0:
		var wave: Dictionary = waves[wave_index]
		var kind: String = wave["kind"]
		var count: int = wave["count"]
		var interval: float = wave["interval"]
		result.append(kind)
		_spawned += 1
		_timer += interval
		if _spawned >= count:
			wave_index += 1
			_spawned = 0
			if not finished():
				var delay: float = waves[wave_index]["delay"]
				_timer += delay
	return result


func run(seconds: float, hz: int = 120) -> Array[String]:
	var result: Array[String] = []
	for i in roundi(seconds * hz):
		result.append_array(step(1.0 / hz))
	return result


func to_dict() -> Dictionary:
	return {"waves": waves.duplicate(true)}


static func from_dict(d: Dictionary) -> WaveSpawner:
	var s := WaveSpawner.new()
	var raw: Array = d.get("waves", [])
	for item in raw:
		var w: Dictionary = item
		s.waves.append({
			"kind": str(w.get("kind", "")),
			"count": int(w.get("count", 0)),
			"interval": float(w.get("interval", 0.0)),
			"delay": float(w.get("delay", 0.0)),
		})
	return s
