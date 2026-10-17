---
id: T-0005
title: Punkte und Rundenzeiten im HUD anzeigen
project: drift
priority: 2
after: T-0003, T-0004
---
## Ziel
`DriftScorer` und `LapTimer` ins Spiel einbauen: Sie laufen in jedem Physik-Frame mit, das HUD zeigt Punkte, Kombo, Runde, Rundenzeit und Bestzeit. Die Labels gibt es schon, sie zeigen bisher „–“.

## Dateien
- `scripts/main.gd`: Wertung und Rundenzeit anlegen und jeden Frame aktualisieren
- `scripts/hud.gd`: zwei neue Anzeige-Methoden
- `tests/test_main_wiring.gd`: neu

## Akzeptanzkriterien
- In `scripts/main.gd`:
  - Neue Variablen `var scorer := DriftScorer.new()` und `var lap_timer: LapTimer`
  - In `_ready()` nach den bestehenden Zeilen: `lap_timer = LapTimer.new(track.path.length)`
  - `_physics_process(_delta: float)` umbenennen in `_physics_process(delta: float)` und nach den bestehenden Zeilen ergänzen:
    ```gdscript
    var pos: Vector2 = car.physics.position
    scorer.update(delta, car.physics.slip_angle_deg(), car.physics.speed(), track.path.is_on_track(pos))
    lap_timer.update(delta, track.path.progress_at(pos))
    hud.show_score(scorer)
    hud.show_laps(lap_timer)
    ```
- In `scripts/hud.gd` zwei neue Methoden:
  - `func show_score(scorer: DriftScorer) -> void`: `score_label.text = "Punkte %d" % scorer.total`. Ist `scorer.current > 0.0`: `combo_label.text = "+%d  x%d" % [roundi(scorer.current), scorer.combo]`, sonst `combo_label.text = ""`.
  - `func show_laps(timer: LapTimer) -> void`: `lap_label.text = "Runde %d" % (timer.lap + 1)`, `time_label.text = "Zeit " + LapTimer.format_time(timer.current_time)`, `best_label.text = "Beste " + LapTimer.format_time(timer.best_lap_time)`.
- `scenes/main.tscn` nicht ändern.

## Tests
Neue Datei `tests/test_main_wiring.gd` mit `extends "res://tests/base_test.gd"` und dieser Methode:
- `test_wertung_und_rundenzeit_sind_verdrahtet`:
  ```gdscript
  var main: Node = load("res://scenes/main.tscn").instantiate()
  (Engine.get_main_loop() as SceneTree).root.add_child(main)
  check(main.scorer is DriftScorer, "main.scorer ist ein DriftScorer")
  check(main.lap_timer is LapTimer, "main.lap_timer ist ein LapTimer")
  check_eq(main.lap_timer.track_length, main.track.path.length, "Rundenlänge = Streckenlänge")
  check(main.hud.has_method("show_score"), "HUD hat show_score")
  check(main.hud.has_method("show_laps"), "HUD hat show_laps")
  main.free()
  ```

Review (15.10.2026, 17:15): gemergt. Funktion genau nach Ticket; vertauschte Kommentare in main.gd korrigiert.
