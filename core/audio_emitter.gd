class_name AudioEmitter
extends RefCounted

## Audioquelle mit Abspielzustand und Entfernung
var stream: String = ""
var volume_db: float = 0.0
var pitch: float = 1.0
var loop: bool = false
var length: float = 0.0
var position: float = 0.0
var state: String = "stopped"
var min_distance: float = 1.0
var max_distance: float = 20.0

func play() -> void:
	if state == "stopped":
		position = 0.0
	elif state == "paused":
		pass  # an derselben Stelle weiter
	state = "playing"

func pause() -> void:
	if state == "playing":
		state = "paused"

func stop() -> void:
	state = "stopped"
	position = 0.0

func step(dt: float) -> void:
	if state != "playing":
		return
	position += dt * pitch
	if length > 0 and position >= length:
		if loop:
			position = fposmod(position, length)
		else:
			stop()

func gain_at(distance: float) -> float:
	if distance <= min_distance:
		return 1.0
	elif distance >= max_distance:
		return 0.0
	else:
		return 1.0 - (distance - min_distance) / (max_distance - min_distance)

func to_dict() -> Dictionary:
	return {
		"stream": stream,
		"volume_db": volume_db,
		"pitch": pitch,
		"loop": loop,
		"length": length,
		"min_distance": min_distance,
		"max_distance": max_distance
	}

static func from_dict(d: Dictionary) -> AudioEmitter:
	var emitter: AudioEmitter = AudioEmitter.new()
	emitter.stream = str(d.get("stream", ""))
	emitter.volume_db = float(d.get("volume_db", 0.0))
	emitter.pitch = float(d.get("pitch", 1.0))
	emitter.loop = bool(d.get("loop", false))
	emitter.length = float(d.get("length", 0.0))
	emitter.min_distance = float(d.get("min_distance", 1.0))
	emitter.max_distance = float(d.get("max_distance", 20.0))
	return emitter
