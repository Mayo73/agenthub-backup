---
id: T-0264
title: Spielerfisch übernimmt die Fähigkeiten seines Ausbaus
project: zellenphase
priority: 4
after: T-0262
---
## Ziel
Der Ausbau soll beim Schwimmen spürbar sein: Sobald der Spielerfisch einen Ausbau bekommt (am Anfang, beim Übergang, nach einer Verbesserung), übernimmt seine Bewegung Tempo, Beschleunigung, Drehen und Neigen aus `FishAbilities`.

## Dateien
- `scripts/fish_player.gd`
- `tests/test_fish_player.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_player.gd`, `set_build(b)`: als letzte Zeile `FishAbilities.apply(b, motion)`.
- In `_init()` direkt nach `model.rebuild(build)` die Zeile `FishAbilities.apply(build, motion)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_player.gd` anhängen (vorhandenes `setup()`/`teardown()` der Datei nutzen):
- `test_faehigkeiten_anfang`: ein neuer `FishPlayer` hat `motion.max_speed` 8.0 und `motion.turn_rate` 1.8
- `test_faehigkeiten_nach_ausbau`: `var b := FishBuild.new()`; zweimal `b.upgrade("schwanz")`; einmal `b.upgrade("flossen")`; `player.set_build(b)` → `player.motion.max_speed` 12.0; `player.motion.accel` 15.0; `player.motion.turn_rate` 2.2 (Toleranz 0,001)
- `test_schneller_ausgebaut`: zwei `FishPlayer`, einer mit Schwanzflosse Stufe 3; beide 3 Sekunden lang in Schritten von 0,1 mit `drive(Vector3(1, 0, 0), 0.1)` → der ausgebaute hat danach ein höheres `motion.speed()`. Beide am Ende mit `free()` freigeben.

Review (17.10.2026): gemergt.
