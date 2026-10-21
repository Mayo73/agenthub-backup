---
id: T-0540
title: WaveSpawner – Gegnerwellen nach Zeitplan
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (2D-Referenzspiel): Ein Zeitplan, der Gegner in Wellen erscheinen lässt. Die Logik liefert nur, was wann erscheinen soll; das Erzeugen der Nodes macht später das Spiel.

## Dateien
- `core/wave_spawner.gd` – neu, Klasse `WaveSpawner`
- `tests/test_wave_spawner.gd` – neu

## Akzeptanzkriterien
`class_name WaveSpawner`, `extends RefCounted`. Vorher `core/command_result.gd` lesen.
- Eine Welle ist ein Dictionary `{"kind": String, "count": int, "interval": float, "delay": float}` (`delay` = Pause vor der Welle in Sekunden, `interval` = Abstand zwischen zwei Gegnern)
- `var waves: Array[Dictionary] = []`, `var wave_index := 0`, `var _spawned := 0`, `var _timer := 0.0`
- `func add_wave(kind: String, count: int, interval: float, delay: float = 0.0) -> CommandResult`: leerer `kind`, `count <= 0` oder `interval < 0` → `CommandResult.INVALID_ARGUMENT`; sonst anhängen, `success({"index": waves.size() - 1})`
- `func start() -> void`: `wave_index = 0`, `_spawned = 0`, `_timer` = `delay` der ersten Welle (ohne Wellen 0.0)
- `func step(dt: float) -> Array[String]`: `_timer -= dt`; solange nicht `finished()` und `_timer <= 0`: `kind` der aktuellen Welle an die Rückgabe anhängen, `_spawned += 1`, `_timer += interval`; ist die Welle voll (`_spawned >= count`), zur nächsten wechseln (`wave_index += 1`, `_spawned = 0`, falls es sie gibt `_timer += delay` der nächsten). Mehrere Gegner in einem Schritt sind möglich
- `func finished() -> bool`: `wave_index >= waves.size()`
- `func run(seconds: float, hz: int = 120) -> Array[String]`: alle Ausgaben von `step(1.0 / hz)` über `roundi(seconds * hz)` Schritte gesammelt
- `func to_dict() -> Dictionary` (`{"waves": [...]}`) und `static func from_dict(d: Dictionary) -> WaveSpawner` (Zahlen aus JSON mit `int(...)` bzw. `float(...)` lesen)

## Tests
`tests/test_wave_spawner.gd`:
- `test_ungueltig`: `add_wave("", 3, 1.0).code` und `add_wave("schleim", 0, 1.0).code` sind „invalid_argument“
- `test_eine_welle`: `add_wave("schleim", 3, 1.0)`, `start()`; `run(0.5)` hat 1 Eintrag, danach `run(2.0)` noch 2, `finished()` true
- `test_zwei_wellen`: `add_wave("schleim", 2, 0.5)`, `add_wave("fledermaus", 1, 0.0, 3.0)`, `start()`; `run(2.0)` ist `["schleim", "schleim"]`; danach enthält `run(3.0)` `"fledermaus"` (sie erscheint etwa bei 4,0 s: letzter Schleim bei 0,5 s, plus Abstand 0,5 s, plus Pause 3,0 s)
- `test_speichern`: Spawner mit zwei Wellen; `WaveSpawner.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))` hat 2 Wellen, und `waves[0]["count"]` ist 2

Review (21.10.2026): von Claude selbst umgesetzt (Agent scheiterte 5x an Typfehlern bei typisierten Arrays), 4 Tests.
