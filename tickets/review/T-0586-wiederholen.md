---
id: T-0586
title: RetryPolicy – KI-Aufrufe wiederholen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“: Vorübergehende Fehler eines KI-Providers (Zeitüberschreitung, Verbindung, überlastet) werden mit wachsender Wartezeit wiederholt, andere nicht.

## Dateien
- `core/retry_policy.gd` – neu, Klasse `RetryPolicy`
- `tests/test_retry_policy.gd` – neu

## Akzeptanzkriterien
`class_name RetryPolicy`, `extends RefCounted`.
- `const RETRYABLE := ["zeitueberschreitung", "verbindung", "ueberlastet"]`
- `var max_attempts := 3`, `var base_delay := 0.5`, `var max_delay := 8.0`
- `func _init(attempts: int = 3, base: float = 0.5, cap: float = 8.0) -> void`
- `func delay(attempt: int) -> float`: Wartezeit nach dem fehlgeschlagenen Versuch `attempt` (ab 1): `minf(base_delay * pow(2.0, attempt - 1), max_delay)`
- `func should_retry(attempt: int, error_code: String) -> bool`: `attempt < max_attempts` und `error_code in RETRYABLE`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs.

## Tests
`tests/test_retry_policy.gd`:
- `test_wartezeit`: `RetryPolicy.new()`: `delay(1)` ist 0.5, `delay(3)` ist 2.0, `delay(10)` ist 8.0
- `test_wiederholen`: `should_retry(1, "verbindung")` wahr; `should_retry(3, "verbindung")` falsch
- `test_nicht_wiederholbar`: `should_retry(1, "ungueltig")` falsch
- `test_eigene_werte`: `RetryPolicy.new(5, 1.0, 3.0)`: `delay(2)` ist 2.0, `delay(4)` ist 3.0, `should_retry(4, "ueberlastet")` wahr
