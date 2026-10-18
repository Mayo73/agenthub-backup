---
id: T-0329
title: SwipeGesture – Wischen nach rechts oder links erkennen
project: sparring
priority: 3
---
## Ziel
Meilenstein „Swipe und Match“: Eine reine Logik-Klasse wertet eine Wischbewegung aus. Nach rechts = Interesse, nach links = überspringen, kurze Bewegungen zählen nicht. Die Karte folgt dabei dem Finger und neigt sich leicht.

## Dateien
- `scripts/swipe_gesture.gd` – neu, Klasse `SwipeGesture`
- `tests/test_swipe_gesture.gd` – neu

## Akzeptanzkriterien
`class_name SwipeGesture`, `extends RefCounted`:
- `const THRESHOLD := 160.0` – Mindeststrecke in x (Pixel)
- `const MAX_TILT := 0.25` – größte Neigung der Karte in Radiant
- `enum Result { NONE, LIKE, PASS }`
- `var active := false`, `var start := Vector2.ZERO`, `var offset := Vector2.ZERO`
- `func begin(pos: Vector2) -> void`: `active = true`, `start = pos`, `offset = Vector2.ZERO`
- `func move(pos: Vector2) -> void`: nur wenn aktiv: `offset = pos - start`
- `func finish() -> int`: nur wenn aktiv, sonst `Result.NONE`. Wertet aus und setzt danach `active = false`, `offset = Vector2.ZERO`. `LIKE`, wenn `offset.x >= THRESHOLD` und `absf(offset.x) > absf(offset.y)`; `PASS`, wenn `offset.x <= -THRESHOLD` und `absf(offset.x) > absf(offset.y)`; sonst `NONE`.
- `func cancel() -> void`: `active = false`, `offset = Vector2.ZERO`
- `func tilt() -> float`: `clampf(offset.x / (THRESHOLD * 2.0), -1.0, 1.0) * MAX_TILT`
- `func preview() -> int`: welches Ergebnis `finish()` jetzt liefern würde, ohne den Zustand zu ändern (für die Einblendung „Interesse“ / „Überspringen“ während des Wischens).

## Tests
`tests/test_swipe_gesture.gd`, in `setup()` `g = SwipeGesture.new()`:
- `test_nach_rechts`: `begin(Vector2(100, 500))`, `move(Vector2(300, 520))` → `preview()` `LIKE`; `finish()` `LIKE`; danach `active` falsch, `offset` null
- `test_nach_links`: von (400, 500) nach (200, 500) → `PASS`
- `test_zu_kurz`: von (100, 500) nach (200, 500) → `NONE`
- `test_eher_senkrecht`: von (100, 100) nach (300, 400) → `NONE`
- `test_ohne_beginn`: `move(Vector2(500, 0))` und `finish()` ohne `begin` → `NONE`
- `test_neigung`: `begin(Vector2.ZERO)`; `move(Vector2(160, 0))` → `tilt()` 0.125; `move(Vector2(1000, 0))` → 0.25; `move(Vector2(-320, 0))` → -0.25
- `test_abbrechen`: `begin`, `move` weit nach rechts, `cancel()`, `finish()` → `NONE`
