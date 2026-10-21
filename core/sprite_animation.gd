class_name SpriteAnimation
extends RefCounted

## Name der Animation
var anim_name: String = ""

## Liste der Bildpfade für die Einzelbilder
var frames: Array[String] = []

## Frames pro Sekunde
var fps: float = 10.0

## Soll die Animation endlos wiederholen?
var loop: bool = true

## Konstruktor
func _init(name_text: String = "", frame_paths: Array[String] = [], frames_per_second: float = 10.0, looping: bool = true) -> void:
	anim_name = name_text
	frames = frame_paths
	fps = frames_per_second
	loop = looping

## Dauer der Animation in Sekunden
func duration() -> float:
	if fps <= 0.0 or frames.size() == 0:
		return 0.0
	return float(frames.size()) / fps

## Frame-Index zum Zeitpunkt t (in Sekunden)
func frame_index(t: float) -> int:
	if frames.size() == 0:
		return -1
	if fps <= 0.0 or t < 0.0:
		return 0
	var i: int = int(floor(t * fps))
	if loop:
		i = i % frames.size()
	else:
		i = mini(i, frames.size() - 1)
	return i

## Bildpfad zum Zeitpunkt t (in Sekunden)
func frame_at(t: float) -> String:
	if frames.size() == 0:
		return ""
	var idx: int = frame_index(t)
	return frames[idx]

## Hat die Animation finished?
func finished(t: float) -> bool:
	if loop:
		return false
	return t >= duration()

## Serialize to Dictionary
func to_dict() -> Dictionary:
	return {
		"name": anim_name,
		"frames": frames,
		"fps": fps,
		"loop": loop
	}

## Deserialize from Dictionary
static func from_dict(d: Dictionary) -> SpriteAnimation:
	var result: SpriteAnimation = SpriteAnimation.new()
	result.anim_name = str(d.get("name", ""))
	var raw_frames: Array = d.get("frames", [])
	for frame in raw_frames:
		result.frames.append(str(frame))
	result.fps = float(d.get("fps", 10.0))
	result.loop = bool(d.get("loop", true))
	return result
