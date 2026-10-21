---
id: T-0544
title: AnimationClip – mehrere Spuren als Animation
project: hub-engine
priority: 4
after: T-0543
---
## Ziel
Muss 4 „einfache Animationen“: eine Animation fasst mehrere Spuren (z. B. `x`, `alpha`) zusammen und liefert zu jedem Zeitpunkt alle Werte. JSON-fähig für Projektdateien.

## Dateien
- `core/animation_clip.gd` – neu, Klasse `AnimationClip`
- `tests/test_animation_clip.gd` – neu

## Akzeptanzkriterien
`class_name AnimationClip`, `extends RefCounted`. Vorher `core/keyframe_track.gd` lesen.
- `var name := ""`, `var loop := false`, `var tracks: Dictionary = {}` (Eigenschaft → `KeyframeTrack`)
- `func track(property: String) -> KeyframeTrack`: vorhandene Spur oder neu angelegte (dann in `tracks` speichern)
- `func key(property: String, t: float, value: float) -> void`: `track(property).add_key(t, value)`
- `func length() -> float`: größte Länge aller Spuren, ohne Spuren 0.0
- `func sample_all(t: float) -> Dictionary`: bei `loop` und `length() > 0` zuerst `t = fposmod(t, length())`; dann je Eigenschaft der Wert `tracks[p].sample(t)`
- `func to_dict() -> Dictionary`: `{"name": name, "loop": loop, "tracks": {eigenschaft: [[t, wert], …]}}`; `static func from_dict(d: Dictionary) -> AnimationClip` (Zahlen mit `float(...)`)

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var tr: KeyframeTrack = tracks[p]`, `var pairs: Array = raw.get(p, [])`).

## Tests
`tests/test_animation_clip.gd`, `setup()`: `clip = AnimationClip.new()`, dann `clip.key("x", 0, 0)`, `clip.key("x", 1, 10)`, `clip.key("alpha", 0, 1)`, `clip.key("alpha", 2, 0)`:
- `test_mehrere`: `length()` 2.0; `sample_all(1.0)` hat `x` 10.0 und `alpha` 0.5
- `test_schleife`: `loop = true`, `sample_all(3.0)` hat `alpha` 0.5 und `x` 10.0
- `test_speichern`: `var d: Dictionary = JSON.parse_string(JSON.stringify(clip.to_dict()))`, `AnimationClip.from_dict(d).sample_all(0.5)` hat `x` 5.0

Review (21.10.2026): gemergt.
