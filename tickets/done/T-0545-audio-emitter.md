---
id: T-0545
title: AudioEmitter – Audioquelle mit Abspielzustand und Entfernung
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „Audioquellen“: das Modell einer Audioquelle mit Abspielen, Pause, Schleife, Tonhöhe und Abschwächung über die Entfernung. Die echte Wiedergabe macht später die Laufzeit mit `AudioStreamPlayer`.

## Dateien
- `core/audio_emitter.gd` – neu, Klasse `AudioEmitter`
- `tests/test_audio_emitter.gd` – neu

## Akzeptanzkriterien
`class_name AudioEmitter`, `extends RefCounted`.
- `var stream := ""` (Pfad), `var volume_db := 0.0`, `var pitch := 1.0`, `var loop := false`, `var length := 0.0` (Sekunden), `var position := 0.0`, `var state := "stopped"` („stopped“, „playing“, „paused“), `var min_distance := 1.0`, `var max_distance := 20.0`
- `func play() -> void`: aus „stopped“ mit `position = 0.0`, aus „paused“ an derselben Stelle weiter; danach `state = "playing"`
- `func pause() -> void`: nur aus „playing“ → „paused“
- `func stop() -> void`: `state = "stopped"`, `position = 0.0`
- `func step(dt: float) -> void`: nur bei „playing“: `position += dt * pitch`; ist `length > 0` und `position >= length`: bei `loop` `position = fposmod(position, length)`, sonst `stop()`
- `func gain_at(distance: float) -> float`: ≤ `min_distance` → 1.0; ≥ `max_distance` → 0.0; sonst `1.0 - (distance - min_distance) / (max_distance - min_distance)`
- `func to_dict() -> Dictionary` (`stream`, `volume_db`, `pitch`, `loop`, `length`, `min_distance`, `max_distance`) und `static func from_dict(d: Dictionary) -> AudioEmitter`

Hinweis Typen: Werte aus Dictionaries mit `float(...)`, `str(...)` bzw. `bool(...)` lesen.

## Tests
`tests/test_audio_emitter.gd`, `setup()`: `a = AudioEmitter.new()`, `a.length = 2.0`:
- `test_abspielen`: `play()`, `step(0.5)` → `position` 0.5, `state` „playing“
- `test_ende`: `play()`, `step(2.5)` → `state` „stopped“, `position` 0.0
- `test_schleife`: `loop = true`, `play()`, `step(2.5)` → `state` „playing“, `position` 0.5
- `test_pause`: `play()`, `step(0.5)`, `pause()`, `step(1.0)` → `position` 0.5; dann `play()`, `step(0.5)` → `position` 1.0
- `test_tonhoehe`: `pitch = 2.0`, `play()`, `step(0.5)` → `position` 1.0
- `test_entfernung`: `gain_at(0.5)` 1.0, `gain_at(10.5)` 0.5, `gain_at(25.0)` 0.0
- `test_speichern`: `stream = "res://klang.ogg"`, `pitch = 1.5` → `AudioEmitter.from_dict(a.to_dict())` hat dieselben `stream`, `pitch` und `length`

Review (21.10.2026): gemergt.
