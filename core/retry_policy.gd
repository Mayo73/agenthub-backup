class_name RetryPolicy
extends RefCounted

## Konstanten für wiederholbare Fehlercodes.
const RETRYABLE := ["zeitueberschreitung", "verbindung", "ueberlastet"]

## Maximale Anzahl von Versuchen insgesamt.
var max_attempts: int = 3
## Basis-Verzögerung in Sekunden vor dem exponentiellen Anstieg.
var base_delay: float = 0.5
## Maximale Verzögerung in Sekunden (Cap).
var max_delay: float = 8.0

## Initialisiert den RetryPolicy mit benutzerdefinierten Werten.
func _init(attempts: int = 3, base: float = 0.5, cap: float = 8.0) -> void:
	max_attempts = attempts
	base_delay = base
	max_delay = cap

## Berechnet die Wartezeit nach dem fehlgeschlagenen Versuch `attempt` (ab 1):
## min(base_delay * 2^(attempt-1), max_delay).
func delay(attempt: int) -> float:
	return minf(base_delay * pow(2.0, attempt - 1), max_delay)

## Gibt zurück, ob ein weiterer Versuch sinnvoll ist:
## - attempt muss kleiner als max_attempts sein
## - error_code muss in RETRYABLE enthalten sein.
func should_retry(attempt: int, error_code: String) -> bool:
	return attempt < max_attempts and error_code in RETRYABLE
