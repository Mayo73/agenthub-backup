---
id: T-0560
title: SpriteAnimation – Einzelbilder einer 2D-Animation abspielen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Sprites und einfache Animationen): Welches Einzelbild einer Sprite-Animation zu einem Zeitpunkt gezeigt wird.

## Dateien
- `core/sprite_animation.gd` – neu, Klasse `SpriteAnimation`
- `tests/test_sprite_animation.gd` – neu

## Akzeptanzkriterien
`class_name SpriteAnimation`, `extends RefCounted`.
- `var anim_name := ""`, `var frames: Array[String] = []` (Bildpfade), `var fps := 10.0`, `var loop := true`
- `func _init(name_text: String = "", frame_paths: Array[String] = [], frames_per_second: float = 10.0, looping: bool = true) -> void`
- `func duration() -> float`: `fps <= 0` oder keine Bilder → 0.0; sonst `frames.size() / fps`
- `func frame_index(t: float) -> int`: keine Bilder → -1; `fps <= 0` oder `t < 0` → 0; `i = int(floor(t * fps))`; bei `loop` `i = i % frames.size()`, sonst `mini(i, frames.size() - 1)`
- `func frame_at(t: float) -> String`: Pfad zu `frame_index(t)`, ohne Bilder ""
- `func finished(t: float) -> bool`: nur ohne `loop`: `t >= duration()`; mit `loop` immer `false`
- `func to_dict() -> Dictionary` (`name`, `frames`, `fps`, `loop`) und `static func from_dict(d: Dictionary) -> SpriteAnimation` (`frames` elementweise mit `str(...)`, `fps` mit `float(...)`)

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Werte aus Dictionaries immer mit Typ lesen (`var raw: Array = d.get("frames", [])`). Einrückung nur mit Tabs.

## Tests
`tests/test_sprite_animation.gd` (Animation „laufen“ mit Bildern `["a.png", "b.png", "c.png", "d.png"]`, 8 fps):
- `test_dauer`: `duration()` ist 0.5
- `test_schleife`: `frame_index(0.0)` 0, `frame_index(0.13)` 1, `frame_index(0.5)` 0, `frame_at(0.4)` „d.png“
- `test_ohne_schleife`: `loop = false`: `frame_index(2.0)` 3, `finished(0.6)` true, `finished(0.2)` false
- `test_leer`: `SpriteAnimation.new().frame_index(1.0)` ist -1, `frame_at(1.0)` ""
- `test_speichern`: über `JSON.parse_string(JSON.stringify(a.to_dict()))` und `from_dict`: 4 Bilder, `fps` 8.0

Review (21.10.2026): gemergt.
