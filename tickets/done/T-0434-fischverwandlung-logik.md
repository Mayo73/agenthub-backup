---
id: T-0434
title: FishMorph – Verlauf der Verwandlung von Zelle zu Fisch
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Die Zelle verwandelt sich im Editor in 2–3 Sekunden in den Fisch: Der Körper streckt sich, die Schwanzflosse wächst, die Farbe bleibt; danach blendet das Bild ins Wasserblau. Diese Klasse rechnet den Verlauf, die Darstellung nutzt ihn.

## Dateien
- `scripts/fish_morph.gd` – neu, Klasse `FishMorph`
- `tests/test_fish_morph.gd` – neu

## Akzeptanzkriterien
`class_name FishMorph`, `extends RefCounted`:
- `const DURATION := 2.5` (Verwandlung), `const FADE := 0.8` (Überblendung danach)
- `var time := 0.0`, `var running := false`
- `func start() -> void`: `time = 0.0`, `running = true`; `func tick(delta: float) -> void`: nur wenn `running`, `time += delta`; ist danach `time >= DURATION + FADE`, `running = false`
- `func morph() -> float`: Fortschritt der Verwandlung 0–1, `smoothstep(0.0, 1.0, clampf(time / DURATION, 0.0, 1.0))`
- `func stretch() -> float`: Länge zu Breite des Körpers, `lerpf(1.0, 2.2, morph())`
- `func tail() -> float`: Länge der Schwanzflosse in Zellradien, `lerpf(0.0, 0.9, morph())`
- `func fade() -> float`: Deckkraft der Überblendung 0–1, `clampf((time - DURATION) / FADE, 0.0, 1.0)`
- `func is_done() -> bool`: `time >= DURATION + FADE`

## Tests
`tests/test_fish_morph.gd`:
- `test_anfang`: nach `start()` → `stretch()` 1.0, `tail()` 0.0, `fade()` 0.0
- `test_mitte`: `start()`, `tick(1.25)` → `morph()` 0.5, `fade()` 0.0
- `test_ende`: `start()`, `tick(2.5)` → `stretch()` 2.2, `tail()` 0.9; `tick(0.4)` → `fade()` 0.5; `tick(0.4)` → `is_done()`, `running` falsch
- `test_ohne_start`: `tick(1.0)` ohne `start()` → `time` 0.0

Review (20.10.2026): gemergt.
