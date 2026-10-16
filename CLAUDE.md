# Drift – Regeln für Agents

2D-Driftspiel in Godot 4.7 mit GDScript, isometrische Ansicht. Spielziel: schnelle Rundenzeiten **und** Drift-Punkte. Ein weiter Drift bringt mehr Punkte, kostet aber Tempo.

## Architektur (wichtig)

- Die gesamte Spiellogik rechnet in **Weltkoordinaten von oben**: x nach rechts, y nach unten, Einheit Pixel. Nur die Darstellung ist isometrisch: Der Knoten `World` in `scenes/main.tscn` bekommt `Iso.TRANSFORM`. Neue Logik rechnet nie mit Bildschirmkoordinaten.
- Für das Auto gibt es keine Godot-Physikkörper (`RigidBody2D`, `CharacterBody2D`). Die Fahrphysik steckt in `CarPhysics`.
- Logik gehört in testbare Klassen (`extends RefCounted`), Nodes nur für Darstellung und Eingabe.

## Dateien

| Datei | Aufgabe |
|---|---|
| `scripts/car_physics.gd` | `CarPhysics`: Fahrphysik, Drift, Abstimmungswerte |
| `scripts/track_path.gd` | `TrackPath`: Mittellinie, `is_on_track()`, `progress_at()` für Runden, `length` |
| `scripts/iso.gd` | `Iso`: Projektion Welt ↔ Bildschirm |
| `scripts/controls.gd` | `Controls`: Aktionen `gas`, `bremse`, `links`, `rechts`, `handbremse`, `zuruecksetzen`, `neustart`, `pause` |
| `scripts/car.gd` | Auto-Node: Eingaben → `CarPhysics` → Position; hat `physics`, `track`, `input_enabled` (Eingaben sperren) und `smoke` (Reifenrauch) |
| `scripts/track.gd` | Zeichnet die Strecke, hat `path: TrackPath`, `track_id`, `load_track(id)` |
| `scripts/hud.gd` | Anzeige; Signale `again_pressed`, `menu_pressed` (Ergebnis-Knöpfe `result_buttons`); Labels `speed_label`, `angle_label`, `drift_label`, `score_label`, `combo_label`, `lap_label`, `time_label`, `best_label`, `countdown_label`, `result_label`; `show_race(race, points)` |
| `scripts/main.gd` | Verdrahtung: `car`, `track`, `camera`, `hud`, `scorer`, `lap_timer`, `race`, `skid_marks`, `ghost`, `ghost_best`, `ghost_recording`, `pause_menu`; `restart()`, `go_to_menu()` |
| `scripts/drift_scorer.gd` | `DriftScorer`: Drift-Punkte und Kombo (`total`) |
| `scripts/lap_timer.gd` | `LapTimer`: Runden, Rundenzeit, Bestzeit, Signal `lap_completed`, `format_time()` |
| `scripts/race_state.gd` | `RaceState`: Countdown, `TOTAL_LAPS` Runden, Ergebnistext, `can_drive()` |
| `scripts/skid_trail.gd` | `SkidTrail`: Punkte einer Reifenspur |
| `scripts/skid_marks.gd` | Zeichnet die Reifenspuren (Node `World/SkidMarks`, im Code angelegt) |
| `scripts/ghost_lap.gd` | `GhostLap`: Aufnahme einer Runde (`record()`, `position_at()`, `heading_at()`, `duration()`) |
| `scripts/ghost_car.gd` | Geisterauto-Node (`World/Ghost`), `show_at(lap, time)` |
| `scripts/track_catalog.gd` | `TrackCatalog`: alle Strecken (`ids()`, `name_of()`, `width_of()`, `points_of()`, `DEFAULT_ID`) |
| `scripts/game_settings.gd` | `GameSettings`: statische Werte über Szenenwechsel hinweg (`track_id`) |
| `scripts/main_menu.gd` | Hauptmenü (`scenes/main_menu.tscn`, Startszene): `start_button`, `settings_button`, `quit_button` |
| `scripts/pause_menu.gd` | Pausemenü (`scenes/pause_menu.tscn`, Esc): `open()`, `close()`, `toggle()`, Signal `restart_requested` |

Zur Laufzeit in `main.gd` nützlich: `car.physics.speed()`, `car.physics.slip_angle_deg()`, `car.physics.is_drifting()`, `car.physics.position`, `track.path.is_on_track(pos)`, `track.path.progress_at(pos)`, `track.path.length`.

## Regeln

- GDScript 4 mit statischen Typen (`var x: int`, `func f() -> void`).
- Einrückung **nur mit Tabs**, niemals mit Leerzeichen.
- Kommentare beginnen mit `#` oder `##`. Es gibt keine Block-Kommentare mit `"""`.
- Zu jeder neuen Logik gehört ein Test in `tests/test_<thema>.gd`:

  ```gdscript
  extends "res://tests/base_test.gd"

  var scorer: DriftScorer

  func setup() -> void:          # optional, läuft vor jedem Test
  	scorer = DriftScorer.new()

  func test_beschreibung() -> void:
  	check_eq(ist_wert, soll_wert, "was geprüft wird")
  	check(bedingung, "was schiefging")
  ```

  Jeder Test bekommt eine frische Instanz der Testklasse; `setup()` und `teardown()` sind optional.
- Abstimmungswerte in `CarPhysics` nur ändern, wenn das Ticket es verlangt. `tests/test_car_physics.gd` hält das Fahrgefühl fest und ist geschützt.
- `project.godot` nur ändern, wenn das Ticket es ausdrücklich verlangt.
- `.tscn`-Dateien vorsichtig bearbeiten: Jede `ext_resource`-/`sub_resource`-ID muss eindeutig sein und zu ihren Verweisen passen.
- Niemals Tests löschen oder abschwächen, nur damit die Prüfung grün wird.

## Stil (Grafik)

Festgelegt am 16.10.2026 mit den ersten Higgsfield-Grafiken (A-0001 bis A-0006). Neue Grafiken passen sich daran an.

- Klare, stilisierte Spielgrafik mit flachen Farben und weichen Verläufen, keine Fotografie, keine Schrift, keine Marken oder Logos.
- Sprites im Spiel (Autos, Deko) sind **genau von oben** gezeichnet; die isometrische Wirkung entsteht durch `Iso.TRANSFORM` am Knoten `World`. Licht von links oben, kein eingebauter Schatten.
- Autos zeigen nach **rechts** (+x, Fahrtrichtung bei `heading = 0`), Bilder in doppelter Auflösung (etwa 104x48 für 52x24 Pixel im Spiel), Hintergrund transparent.
- Menü-Bilder (z. B. `assets/menu/title_background.png`, 1280x720) dürfen isometrisch von schräg oben gezeigt sein, mit Abendlicht.
- Farben: Wiese etwa `#295C33`, Asphalt dunkelgrau, Randsteine rot-weiß. Autos: Allrounder rot, Grip-Coupé blau, Drift-Kombi gelb.

| Datei | Inhalt |
|---|---|
| `assets/menu/title_background.png` | Hintergrund des Hauptmenüs, 1280x720 |
| `assets/cars/car_allround.png`, `car_grip.png`, `car_drifter.png` | Autos von oben, Front nach rechts, 104x46 bis 104x48 |
| `assets/decor/tree.png` | Baumkrone von oben, 123x128 |
| `assets/decor/tires.png` | drei Reifenstapel in einer Reihe, 125x52 |
