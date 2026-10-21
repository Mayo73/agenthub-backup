---
id: T-0536
title: FireControl – Schussrate, Magazin und Nachladen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Ballistik im Referenzspiel): Regelt, wann eine Waffe feuern darf: Abstand zwischen Schüssen, Magazin und Nachladezeit. Zeit läuft nur über `step(dt)`, damit Tests deterministisch sind.

## Dateien
- `core/fire_control.gd` – neu, Klasse `FireControl`
- `tests/test_fire_control.gd` – neu

## Akzeptanzkriterien
`class_name FireControl`, `extends RefCounted`.
- `var rate := 4.0` (Schüsse pro Sekunde), `var magazine_size := 6`, `var reload_time := 1.5`, `var ammo := 6`, `var _cooldown := 0.0`, `var _reload_left := 0.0`
- `func _init(rate_value: float = 4.0, magazine: int = 6, reload_seconds: float = 1.5) -> void`: Werte setzen, `ammo = magazine`
- `func is_reloading() -> bool`: `_reload_left > 0.0`
- `func can_fire() -> bool`: nicht beim Nachladen, `ammo > 0` und `_cooldown <= 0.0`
- `func fire() -> bool`: wenn `can_fire()`: `ammo -= 1`, `_cooldown = 1.0 / rate`, bei `ammo == 0` automatisch `reload()`, `true`; sonst `false`
- `func reload() -> bool`: schon beim Nachladen oder Magazin voll → `false`; sonst `_reload_left = reload_time`, `true`
- `func step(dt: float) -> void`: `_cooldown = maxf(_cooldown - dt, 0.0)`; beim Nachladen `_reload_left -= dt`, erreicht es ≤ 0: `_reload_left = 0.0`, `ammo = magazine_size`
- `func shots_in(seconds: float, hz: int = 120) -> int`: Hilfsfunktion für Tests und Abnahme: `roundi(seconds * hz)` Schritte, in jedem erst `fire()` versuchen, dann `step(1.0 / hz)`; zählt die erfolgreichen Schüsse

## Tests
`tests/test_fire_control.gd`:
- `test_abstand`: `FireControl.new(4.0, 6, 1.5)`: `fire()` true, sofort nochmal false, nach `step(0.25)` true
- `test_magazin_leer`: `FireControl.new(100.0, 2, 1.0)`: zwei Schüsse mit `step(0.02)` dazwischen → `ammo` 0, `is_reloading()` true, `fire()` false
- `test_nachladen`: wie oben leer schießen, `step(1.0)` → `ammo` 2, `is_reloading()` false
- `test_voll_kein_nachladen`: neues Objekt → `reload()` false
- `test_schuesse_pro_sekunde`: `FireControl.new(4.0, 100, 1.0).shots_in(2.0)` ist 8

Review (21.10.2026): gemergt.
