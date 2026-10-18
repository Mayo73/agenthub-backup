---
id: T-0289
title: Lichtstrahlen in der Fischszene
project: zellenphase
priority: 4
after: T-0286, T-0288
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Lichtstrahlen“: Die Lichtstrahlen (`LightRays`) erscheinen in der Fischszene und folgen der Kamera.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Variable `var rays: LightRays` unter `var snow: MarineSnow`.
- In `_ready()` direkt nach `add_child(snow)`:
```gdscript
	rays = LightRays.new()
	rays.name = "Rays"
	world.add_child(rays)
```
- In `_process(delta)` direkt nach `snow.position = camera.position` die Zeile `rays.update(camera.position, delta)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_lichtstrahlen_knoten`: `fish.get_node("World/Rays") is LightRays` wahr
- `test_lichtstrahlen_folgen`: `fish.camera.position = Vector3(12, -10, 4)`; `fish.rays.update(fish.camera.position, 0.1)` → `fish.rays.position.x` ist 12.0, `fish.rays.position.z` ist 4.0
- `test_lichtstrahlen_in_process`: `fish._process(0.1)` → `fish.rays.position.x` ist `fish.camera.position.x` (Toleranz über `check_eq` reicht)

Review (18.10.2026): gemergt.
