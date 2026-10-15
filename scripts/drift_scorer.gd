class_name DriftScorer
extends RefCounted

## Mindestwinkel für einen Drift (Grad)
const MIN_ANGLE := 12.0
## Mindestdrehzahl für Punkte (Einheit)
const MIN_SPEED := 150.0
## Zeitfenster für Ketten-Drifts (Sekunden)
const CHAIN_TIME := 1.5
## Maximale Kombo
const MAX_COMBO := 5

## Signale
signal drift_banked(points: int)
signal drift_failed

## Laufende Variable
var total := 0
var current := 0.0
var combo := 1
var drifting := false

## Zeit die seit dem letzten Drift-Ende verstrichen ist (akkumuliert via delta)
var _pause_seconds := 0.0


func reset() -> void:
	total = 0
	current = 0.0
	combo = 1
	drifting = false
	_pause_seconds = 0.0


func update(delta: float, slip_angle_deg: float, speed: float, on_track: bool) -> void:
	# Abflug: wenn nicht auf der Strecke und current > 0
	if not on_track and current > 0.0:
		current = 0.0
		combo = 1
		drifting = false
		_pause_seconds = 0.0
		drift_failed.emit()
		return

	# Prüfen, ob ein Drift läuft
	var is_drift := absf(slip_angle_deg) >= MIN_ANGLE and speed >= MIN_SPEED and on_track

	if drifting:
		if is_drift:
			# Drift läuft weiter, Punkte sammeln
			current += absf(slip_angle_deg) * speed * delta / 100.0
		else:
			# Drift vorbei
			drifting = false
	elif current > 0.0 and not is_drift:
		# Pause während current > 0, zähle Zeit seit Drift-Ende
		_pause_seconds += delta
		if _pause_seconds >= CHAIN_TIME:
			total += roundi(current * combo)
			drift_banked.emit(total)
			current = 0.0
			combo = 1
			_pause_seconds = 0.0
	elif current > 0.0 and is_drift:
		# Neuer Drift während current > 0
		if _pause_seconds < CHAIN_TIME:
			# Innerhalb Kettenzeit, Kombo erhöhen
			combo = min(combo + 1, MAX_COMBO)
			drifting = true
			current += absf(slip_angle_deg) * speed * delta / 100.0
			_pause_seconds = 0.0
		else:
			# Außerhalb Kettenzeit, neuer Drift ohne Kombo
			drifting = true
			current += absf(slip_angle_deg) * speed * delta / 100.0
	elif not drifting and current <= 0.0 and is_drift:
		# Völlig neuer Drift
		drifting = true
		current += absf(slip_angle_deg) * speed * delta / 100.0
