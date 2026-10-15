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
| `scripts/controls.gd` | `Controls`: Aktionen `gas`, `bremse`, `links`, `rechts`, `handbremse`, `zuruecksetzen`, `neustart` |
| `scripts/car.gd` | Auto-Node: Eingaben → `CarPhysics` → Position; hat `physics`, `track`, `input_enabled` (Eingaben sperren) und `smoke` (Reifenrauch) |
| `scripts/track.gd` | Zeichnet die Strecke, hat `path: TrackPath` |
| `scripts/hud.gd` | Anzeige; Labels `speed_label`, `angle_label`, `drift_label`, `score_label`, `combo_label`, `lap_label`, `time_label`, `best_label`, `countdown_label`, `result_label`; `show_race(race, points)` |
| `scripts/main.gd` | Verdrahtung: `car`, `track`, `camera`, `hud`, `scorer`, `lap_timer`, `race`, `skid_marks`; `restart()` |
| `scripts/drift_scorer.gd` | `DriftScorer`: Drift-Punkte und Kombo (`total`) |
| `scripts/lap_timer.gd` | `LapTimer`: Runden, Rundenzeit, Bestzeit, Signal `lap_completed`, `format_time()` |
| `scripts/race_state.gd` | `RaceState`: Countdown, `TOTAL_LAPS` Runden, Ergebnistext, `can_drive()` |
| `scripts/skid_trail.gd` | `SkidTrail`: Punkte einer Reifenspur |
| `scripts/skid_marks.gd` | Zeichnet die Reifenspuren (Node `World/SkidMarks`, im Code angelegt) |

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
