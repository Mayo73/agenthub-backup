---
id: T-0047
title: Aktueller Platz im HUD
project: drift
priority: 3
after: T-0044, T-0046
---
## Ziel
Während des Rennens zeigt das HUD oben rechts unter der Bestzeit den aktuellen Platz, z. B. `Platz 2/4`. Nach dem Zieleinlauf bleibt der Platz stehen.

## Dateien
- `scenes/main.tscn`
- `scripts/hud.gd`
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scenes/main.tscn`: ganz am Ende der Datei anhängen (keine neue `ext_resource`, sonst nichts ändern):
  ```
  [node name="Place" type="Label" parent="HUD"]
  anchor_left = 1.0
  anchor_right = 1.0
  offset_left = -324.0
  offset_top = 112.0
  offset_right = -24.0
  offset_bottom = 146.0
  theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
  theme_override_constants/outline_size = 6
  theme_override_font_sizes/font_size = 26
  text = "Platz –"
  horizontal_alignment = 2
  ```
- `hud.gd`: `@onready var place_label: Label = $Place` und
  ```gdscript
  func show_place(place: int, total: int) -> void:
  	place_label.text = "Platz %d/%d" % [place, total]
  ```
- `main.gd`:
  - neue Variable `var place := 1`
  - neue Funktion:
    ```gdscript
    func ai_distances() -> Array:
    	var result := []
    	for ai in ai_cars:
    		result.append(ai.race_distance())
    	return result
    ```
  - in `_physics_process` im Block `if race.phase == RaceState.Phase.RACING:` als letzte Zeile: `place = RaceRanking.place(lap_timer.distance(), ai_distances())`
  - in `_physics_process` direkt nach `hud.show_laps(lap_timer)`: `hud.show_place(place, ai_cars.size() + 1)`
  - in `restart()` zusätzlich `place = 1`
  - sonst nichts an `main.gd` ändern

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_platz_im_hud` anhängen:
- `main.place` ist 1
- `main.ai_distances().size()` ist 3
- `main.hud.show_place(2, 4)` → `main.hud.place_label.text` ist `"Platz 2/4"`
- `main.place = 3`, `main.restart()` → `main.place` ist 1

Review (16.10.2026): gemergt, nachgebessert: Platzberechnung in den RACING-Block verschoben.
