---
id: T-0107
title: Spielerzelle übernimmt ihren Aufbau
project: zellenphase
priority: 3
after: T-0104
---
## Ziel
Die Spielerzelle hat einen Aufbau (`CellBuild`). Tempo, Wendigkeit und Ernährung werden daraus und aus dem Größenabschnitt berechnet, damit Umbauten im Editor später wirklich wirken.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/player_cell.gd`: neue Variablen direkt unter `var diet := Diet.PFLANZENFRESSER`:
```gdscript
var build := CellBuild.starter(Diet.PFLANZENFRESSER)
var stage := 0
```
- Die bisherige Funktion `set_stage` (mit ihrem Kommentar) ersetzen durch genau diese drei Funktionen:
```gdscript
## Passt Größe und Tempo an den Größenabschnitt an (0 bis 4).
func set_stage(p_stage: int) -> void:
	stage = p_stage
	refresh()


## Übernimmt einen neuen Aufbau (z. B. nach dem Zelleditor).
func set_build(p_build: CellBuild) -> void:
	build = p_build
	refresh()


## Rechnet Größe, Tempo, Wendigkeit und Ernährung aus Größenabschnitt und Aufbau neu aus.
func refresh() -> void:
	radius = CellProgress.radius_for_stage(stage)
	motion.max_speed = CellStats.max_speed(build, stage)
	motion.turn_rate = CellStats.turn_rate(build)
	var d := CellStats.diet(build)
	if d != "":
		diet = d
	queue_redraw()
```
- Sonst nichts an `player_cell.gd` ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_startaufbau`: `cell.build.mouths().size()` ist 1, `cell.build.mouths()[0]` ist `"filtermaul"`, `cell.stage` ist 0
- `test_aufbau_uebernehmen`: `var b := CellBuild.starter(Diet.FLEISCHFRESSER)`, `b.add_part("geissel", Vector2(-1, 0))`, `cell.set_build(b)` → `cell.diet` ist `Diet.FLEISCHFRESSER`, `cell.motion.max_speed` ist 280.0, `cell.motion.turn_rate` ist 6.0; danach `cell.set_stage(1)` → `cell.motion.max_speed` ist 310.0, `cell.radius` ist 18.0
- `test_wimpern_wendiger`: `var b := CellBuild.starter(Diet.PFLANZENFRESSER)`, `b.add_part("wimpern", Vector2(0, 1))`, `cell.set_build(b)` → `cell.motion.turn_rate` ist 9.0
- `test_ohne_maul_bleibt_ernaehrung`: `cell.diet = Diet.FLEISCHFRESSER`, `cell.set_build(CellBuild.new())` → `cell.diet` ist weiterhin `Diet.FLEISCHFRESSER`

Review (16.10.2026): gemergt.
