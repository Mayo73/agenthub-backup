class_name EyeLook
extends RefCounted
## Augen: Lage, Größe, Blickrichtung der Pupille und Blinzeln.

const PUPIL_RANGE := 0.45
const BLINK_PERIOD := 4.0
const BLINK_TIME := 0.15
const STALK_FACTOR := 1.35


## Lage der Pupille relativ zur Augenmitte; look_dir in Zellkoordinaten (Länge beliebig).
static func pupil_offset(look_dir: Vector2, eye_radius: float) -> Vector2:
	if look_dir.length() < 0.001:
		return Vector2.ZERO
	return look_dir.normalized() * eye_radius * PUPIL_RANGE


## 1 = offen, 0,1 = zu. phase verschiebt das Blinzeln, damit nicht alle Augen gleichzeitig blinzeln.
static func openness(time: float, phase: float = 0.0) -> float:
	var t := fposmod(time + phase, BLINK_PERIOD)
	return 0.1 if t < BLINK_TIME else 1.0


## Augenmitte in Pixeln relativ zur Zellmitte; das Stielauge sitzt weiter außen.
static func eye_center(part: Dictionary, radius: float) -> Vector2:
	var pos: Vector2 = part["pos"]
	if part["id"] == "stielauge":
		return pos * radius * STALK_FACTOR
	return pos * radius


static func eye_radius(id: String, radius: float) -> float:
	return radius * (0.18 if id == "stielauge" else 0.13)
