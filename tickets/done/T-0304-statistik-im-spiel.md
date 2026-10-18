---
id: T-0304
title: Statistik der Fischphase im Spiel zählen und in der Pause zeigen
project: zellenphase
priority: 3
after: T-0303, T-0302
---
## Ziel
Die Fischszene führt eine `FishStats` (T-0303): Jeder gefressene KI-Fisch, jeder Tod und die größte Tiefe werden gezählt. Die Zusammenfassung erscheint beim Öffnen der Pause als Meldung.

## Dateien
- `scripts/fish_main.gd` – Zählen und Meldung
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_main.gd`:
  - Neue Variable `var stats := FishStats.new()` direkt unter `var deaths := 0`.
  - In `player_bites()` direkt nach `remove_fish(f)` (im Zweig, in dem der gebissene Fisch stirbt) die Zeile `stats.record_eaten(f.species_id)`. Achtung: `f.species_id` vor `remove_fish(f)` in einer Variable merken (`var id := f.species_id`), weil `remove_fish` den Knoten freigibt; dann `stats.record_eaten(id)` und für `FishSpecies.data(...)` ebenfalls `id` verwenden.
  - In `check_death()` direkt nach `deaths += 1` die Zeile `stats.record_death()`.
  - In `_physics_process(delta)` direkt nach `hud.show_depth(player.motion.depth())` die Zeile `stats.record_depth(player.motion.depth())`.
  - In `toggle_pause()` im Zweig `if paused:` nach `pause_menu.open()` die Zeile `hud.show_message(stats.summary(), 6.0)`.
- Sonst nichts ändern.

## Tests
`tests/test_fish_main.gd`, anhängen (vorher `_clear_ai_fishes()` aufrufen):
- `test_statistik_fressen`: `fish.player.build.diet = Diet.FLEISCHFRESSER`; `var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point())`; `f.health.hp = 1.0`; `fish.player_bites()` → `fish.stats.total_eaten()` ist 1 und `fish.stats.eaten["silberling"]` ist 1
- `test_statistik_tod`: `fish.player_health.hp = 0.0`; `fish.check_death()` → `fish.stats.deaths` ist 1
- `test_statistik_tiefe`: `fish.player.motion.position = Vector3(0, -35, 0)`; `fish._physics_process(0.016)` → `fish.stats.max_depth` ist mindestens 34.0
- `test_statistik_in_pause`: `fish.stats.record_death()`; `fish.toggle_pause()` → `fish.hud.message_label.visible` wahr und `fish.hud.message_label.text` ist `fish.stats.summary()`; danach `fish.toggle_pause()` (wieder aus)

Review (18.10.2026): gemergt.
