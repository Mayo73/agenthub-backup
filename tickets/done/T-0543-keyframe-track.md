---
id: T-0543
title: KeyframeTrack – Zahlenwerte über die Zeit animieren
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „einfache Animationen“: eine Spur mit Schlüsselbildern, zwischen denen linear interpoliert wird.

## Dateien
- `core/keyframe_track.gd` – neu, Klasse `KeyframeTrack`
- `tests/test_keyframe_track.gd` – neu

## Akzeptanzkriterien
`class_name KeyframeTrack`, `extends RefCounted`.
- `var keys: Array[Dictionary] = []` (je `{"t": float, "value": float}`, nach `t` sortiert), `var loop := false`
- `func add_key(t: float, value: float) -> void`: gibt es schon einen Schlüssel mit fast gleichem `t` (Abstand < 0.0001), nur dessen Wert ersetzen; sonst an der richtigen Stelle einfügen (`keys.insert`)
- `func length() -> float`: `t` des letzten Schlüssels, ohne Schlüssel 0.0
- `func sample(t: float) -> float`: keine Schlüssel → 0.0; ein Schlüssel → sein Wert; bei `loop` und `length() > 0` zuerst `t = fposmod(t, length())`; `t` ≤ erstes `t` → erster Wert; `t` ≥ letztes `t` → letzter Wert; sonst linear zwischen den beiden Nachbarn (`lerpf`)

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var kt: float = keys[i]["t"]`).

## Tests
`tests/test_keyframe_track.gd`:
- `test_sortiert`: `add_key(1, 10)`, `add_key(0, 0)`, `add_key(2, 0)` → `keys[1]["t"]` 1.0, `length()` 2.0
- `test_zwischenwerte`: Schlüssel (0, 0) und (1, 10) → `sample(0.5)` 5.0, `sample(-1)` 0.0, `sample(3)` 10.0
- `test_ersetzen`: `add_key(1, 10)`, `add_key(1, 20)` → `keys.size()` 1, `sample(1)` 20.0
- `test_schleife`: Schlüssel (0, 0) und (2, 10), `loop = true` → `sample(3.0)` 5.0
- `test_leer`: neue Spur → `sample(1.0)` 0.0

Review (21.10.2026): gemergt.
