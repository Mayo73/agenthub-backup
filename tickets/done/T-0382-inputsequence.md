---
id: T-0382
title: InputSequence – Testeingaben je Simulationsschritt, gehaltene und gleichzeitige Tasten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Ballistik und Testeingaben“ (Lastenheft Muss 10, Abnahmekriterium 9): Eine Testeingabe hält eine Taste über 120 Schritte, kombiniert zeitweise eine zweite und lässt beide los. Bei Abbruch bleibt keine Taste gedrückt.

## Dateien
- `core/input_sequence.gd` – neu, Klasse `InputSequence`
- `tests/test_input_sequence.gd` – neu

## Akzeptanzkriterien
`class_name InputSequence`, `extends RefCounted`:
- `var holds: Array[Dictionary] = []` – je `{"action": String, "from": int, "to": int}`; gedrückt gilt für `from <= schritt < to`
- `func hold(action: String, from_step: int, to_step: int) -> void` (ignoriert, wenn `to_step <= from_step`)
- `func tap(action: String, step: int) -> void`: wie `hold(action, step, step + 1)`
- `func is_pressed(action: String, step: int) -> bool`
- `func pressed_at(step: int) -> Array[String]`: gedrückte Aktionen, sortiert, ohne Doppelte
- `func events() -> Array[Dictionary]`: je Halten zwei Ereignisse `{"step": from, "action": action, "pressed": true}` und `{"step": to, "action": action, "pressed": false}`; sortiert nach `step`, bei gleichem Schritt Loslassen vor Drücken, dann nach `action`
- `func length() -> int`: größtes `to` (0 ohne Einträge)
- `func abort(step: int) -> Array[Dictionary]`: Loslass-Ereignisse `{"step": step, "action": action, "pressed": false}` für alles, was bei `step` gedrückt ist (nach Aktion sortiert)
- `func to_dict() -> Dictionary` (`{"holds": holds}`) und `static func from_dict(d: Dictionary) -> InputSequence` (Schritte mit `int(...)`)

## Tests
`tests/test_input_sequence.gd`, in `setup()` `seq = InputSequence.new()`, `seq.hold("rechts", 0, 120)`, `seq.hold("springen", 40, 60)`:
- `test_gehalten`: `pressed_at(0)` `["rechts"]`, `pressed_at(50)` `["rechts", "springen"]`, `pressed_at(60)` `["rechts"]`, `pressed_at(119)` `["rechts"]`, `pressed_at(120)` `[]`
- `test_ereignisse`: `events().size()` 4, erstes `{"step": 0, "action": "rechts", "pressed": true}`, letztes `{"step": 120, "action": "rechts", "pressed": false}`
- `test_laenge`: `length()` 120
- `test_abbruch`: `abort(50)` → 2 Ereignisse, beide `pressed` falsch, Aktionen „rechts“ und „springen“; `abort(200)` → leer
- `test_tippen`: `tap("schuss", 10)` → `is_pressed("schuss", 10)` wahr, `is_pressed("schuss", 11)` falsch
- `test_ungueltig`: `hold("x", 5, 5)` → `holds.size()` bleibt 2
- `test_speichern_laden`: `InputSequence.from_dict(JSON.parse_string(JSON.stringify(seq.to_dict())))` → `pressed_at(50)` gleich, `typeof(holds[0]["from"])` `TYPE_INT`

Review (19.10.2026): gemergt, nachgebessert: pressed_at entfernt Doppelte, Test test_ohne_doppelte.
