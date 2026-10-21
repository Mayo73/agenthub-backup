---
id: T-0535
title: Health – Lebenspunkte, Schaden und Heilen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Referenzspiele in 2D und 3D): Ein wiederverwendbarer Baustein für Lebenspunkte mit kurzer Unverwundbarkeit nach einem Treffer. Reine Logik ohne Nodes.

## Dateien
- `core/health.gd` – neu, Klasse `Health`
- `tests/test_health.gd` – neu

## Akzeptanzkriterien
`class_name Health`, `extends RefCounted`.
- `var max_hp := 100.0`, `var hp := 100.0`, `var invulnerable_time := 0.0` (Sekunden Schutz nach einem Treffer, 0 = keiner), `var _protect := 0.0`
- `func _init(max_value: float = 100.0) -> void`: `max_hp = max_value`, `hp = max_value`
- `func is_dead() -> bool`: `hp <= 0.0`
- `func damage(amount: float) -> float`: bei `amount <= 0`, `is_dead()` oder `_protect > 0` → 0.0 zurück, nichts ändern; sonst `hp = maxf(hp - amount, 0.0)`, `_protect = invulnerable_time`, den tatsächlich abgezogenen Wert zurückgeben
- `func heal(amount: float) -> float`: tot oder `amount <= 0` → 0.0; sonst `hp = minf(hp + amount, max_hp)`, den tatsächlich geheilten Wert zurückgeben
- `func step(dt: float) -> void`: `_protect = maxf(_protect - dt, 0.0)`
- `func ratio() -> float`: `hp / max_hp` (bei `max_hp <= 0` 0.0)
- `func to_dict() -> Dictionary` (`max_hp`, `hp`, `invulnerable_time`) und `static func from_dict(d: Dictionary) -> Health`

## Tests
`tests/test_health.gd`:
- `test_schaden`: `Health.new(50.0)`, `damage(20.0)` gibt 20.0, `hp` 30.0, `ratio()` 0.6
- `test_nicht_unter_null`: `Health.new(10.0)`, `damage(25.0)` gibt 10.0, `is_dead()` true, danach `heal(5.0)` gibt 0.0
- `test_heilen_begrenzt`: `Health.new(100.0)`, `damage(30.0)`, `heal(50.0)` gibt 30.0, `hp` 100.0
- `test_schutzzeit`: `invulnerable_time = 0.5`, `damage(10.0)` → 10.0, sofort `damage(10.0)` → 0.0, nach `step(0.6)` `damage(10.0)` → 10.0
- `test_speichern`: `Health.from_dict(h.to_dict())` mit `max_hp` 80, `hp` 35 und `invulnerable_time` 0.25 liefert dieselben Werte

Review (21.10.2026): gemergt.
