class_name EngineAudio
extends RefCounted
## Rechnet den Fahrzustand in Klangwerte um (Tonhöhe, Lautstärke). Spielt selbst nichts ab.

const MIN_PITCH := 0.6
const MAX_PITCH := 2.0
const SILENT_DB := -80.0


## Tonhöhe des Motors: MIN_PITCH im Stand, MAX_PITCH bei Höchsttempo (und darüber).
static func pitch_for(speed: float, max_speed: float) -> float:
	if max_speed <= 0.0:
		return MIN_PITCH
	return lerpf(MIN_PITCH, MAX_PITCH, clampf(speed / max_speed, 0.0, 1.0))


## Motorlautstärke: -16 dB ohne Gas, -6 dB bei Vollgas.
static func engine_db(throttle: float) -> float:
	return lerpf(-16.0, -6.0, clampf(throttle, 0.0, 1.0))


## Reifenquietschen: still ohne Drift; im Drift -18 dB bei 12° Schräglauf bis -6 dB ab 45°.
static func squeal_db(drifting: bool, slip_angle_deg: float) -> float:
	if not drifting:
		return SILENT_DB
	var t := clampf((absf(slip_angle_deg) - 12.0) / 33.0, 0.0, 1.0)
	return lerpf(-18.0, -6.0, t)
