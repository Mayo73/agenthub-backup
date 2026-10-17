---
id: T-0012
title: Countdown und Ergebnis im HUD anzeigen
project: drift
priority: 3
after: T-0011
---
## Ziel
Das HUD zeigt groß in der Mitte den Countdown („3“, „2“, „1“, „Los!“) und nach dem Ziel das Ergebnis aus `RaceState.result_text()`. Außerdem zeigt die Rundenanzeige „Runde 2/3“ statt „Runde 2“.

## Dateien
- `scenes/main.tscn`: zwei neue Labels unter `HUD`
- `scripts/hud.gd`: neue Funktion `show_race`
- `scripts/main.gd`: `show_race` aufrufen

## Akzeptanzkriterien
- `scenes/main.tscn`: ganz am Ende der Datei zwei neue Nodes anhängen (keine neuen `ext_resource` nötig, sonst nichts ändern):

  ```
  [node name="Countdown" type="Label" parent="HUD"]
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -200.0
  offset_top = -120.0
  offset_right = 200.0
  offset_bottom = -20.0
  theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
  theme_override_constants/outline_size = 10
  theme_override_font_sizes/font_size = 72
  horizontal_alignment = 1
  vertical_alignment = 1

  [node name="Result" type="Label" parent="HUD"]
  visible = false
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -250.0
  offset_top = -110.0
  offset_right = 250.0
  offset_bottom = 110.0
  theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
  theme_override_constants/outline_size = 8
  theme_override_font_sizes/font_size = 32
  horizontal_alignment = 1
  vertical_alignment = 1
  ```
- `scripts/hud.gd`:
  - `@onready var countdown_label: Label = $Countdown` und `@onready var result_label: Label = $Result` bei den anderen Labels
  - `func show_race(race: RaceState, points: int) -> void:` setzt `countdown_label.text = race.countdown_text()`; `result_label.visible = race.phase == RaceState.Phase.FINISHED`; ist es sichtbar, `result_label.text = race.result_text(points)`
  - in `show_laps`: `lap_label.text = "Runde %d/%d" % [mini(timer.lap + 1, RaceState.TOTAL_LAPS), RaceState.TOTAL_LAPS]`
- `scripts/main.gd`: in `_physics_process` nach `hud.show_laps(lap_timer)` die Zeile `hud.show_race(race, scorer.total)`

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_rennanzeige` anhängen (bestehende Tests nicht ändern):
- `main.hud.has_method("show_race")` ist wahr
- `main.hud.show_race(main.race, 0)` → `main.hud.countdown_label.text` ist `"3"`, `main.hud.result_label.visible` ist falsch
- `main.race.phase = RaceState.Phase.FINISHED`, `main.hud.show_race(main.race, 42)` → `main.hud.result_label.visible` ist wahr, `main.hud.result_label.text.contains("Punkte 42")` ist wahr
- `main.hud.show_laps(main.lap_timer)` → `main.hud.lap_label.text` ist `"Runde 1/3"`

Review (15.10.2026): gemergt.
