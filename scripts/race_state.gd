class_name RaceState
extends RefCounted

## Enum für Phasen eines Rennens
enum Phase { COUNTDOWN, RACING, FINISHED }

## Konstanten für Rennablauf
const COUNTDOWN_SECONDS := 3.0
const TOTAL_LAPS := 3

## Variablen mit Startwerten
var phase: Phase = Phase.COUNTDOWN
var countdown: float = COUNTDOWN_SECONDS
var race_time: float = 0.0
var lap_times: Array[float] = []


## Aktualisiert den Rennstatus pro Frame
func update(delta: float) -> void:
	match phase:
		Phase.COUNTDOWN:
			countdown -= delta
			if countdown <= 0.0:
				countdown = 0.0
				phase = Phase.RACING
		Phase.RACING:
			race_time += delta
		Phase.FINISHED:
			pass


## Wird aufgerufen, wenn eine Runde abgeschlossen ist
func on_lap(time: float) -> void:
	if phase == Phase.RACING:
		lap_times.append(time)
		if lap_times.size() >= TOTAL_LAPS:
			phase = Phase.FINISHED


## Prüft, ob gefahren werden darf
func can_drive() -> bool:
	return phase == Phase.RACING


## Gibt den Countdown-Text zurück
func countdown_text() -> String:
	match phase:
		Phase.COUNTDOWN:
			return str(ceili(countdown))
		Phase.RACING:
			if race_time < 1.0:
				return "Los!"
		_:
			pass
	return ""


## Gibt die beste Rundzeit zurück oder -1.0 wenn keine Runden gefahren wurden
func best_lap() -> float:
	if lap_times.is_empty():
		return -1.0
	var best := lap_times[0]
	for t in lap_times:
		if t < best:
			best = t
	return best


## Erstellt den Ergebnistext mit Punkten
func result_text(points: int, new_time: bool = false, new_points: bool = false) -> String:
	var text := "Ziel!\nGesamtzeit %s\nBeste Runde %s\nPunkte %d" \
		% [LapTimer.format_time(race_time), LapTimer.format_time(best_lap()), points]
	if new_time:
		text += "\nNeue Bestzeit!"
	if new_points:
		text += "\nNeuer Punkterekord!"
	text += "\nEnter: neues Rennen"
	return text


## Setzt alle Variablen auf ihre Startwerte zurück
func reset() -> void:
	phase = Phase.COUNTDOWN
	countdown = COUNTDOWN_SECONDS
	race_time = 0.0
	lap_times.clear()
