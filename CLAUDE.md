# Testspiel – Regeln für Agents

Godot 4.7 mit GDScript. 2D-Plattformer: Der Spieler läuft, springt und sammelt Münzen.

## Aufbau

- `scenes/` – Szenen (`.tscn`, Textformat)
- `scripts/` – Spiellogik
- `tests/` – automatische Tests: `base_test.gd` (Basisklasse), `test_*.gd` (Tests), `run_tests.gd` (Runner)
- `verify.cmd` – automatische Prüfung: lädt alle Skripte, startet jede Szene kurz und führt alle Tests aus

## Regeln

- GDScript 4 mit statischen Typen (`var x: int`, `func f() -> void`).
- Einrückung **nur mit Tabs**, niemals mit Leerzeichen.
- Testbare Logik gehört in eigene Klassen ohne Szenenabhängigkeit (Vorbild: `scripts/game_state.gd`), nicht in Szenen-Skripte.
- Zu jeder neuen Logik gehört ein Test in `tests/test_<thema>.gd`:

  ```gdscript
  extends "res://tests/base_test.gd"

  var state: GameState

  func setup() -> void:          # optional, läuft vor jedem Test
  	state = GameState.new()

  func test_beschreibung() -> void:
  	check_eq(ist_wert, soll_wert, "was geprüft wird")
  	check(bedingung, "was schiefging")
  ```

  Jeder Test bekommt eine frische Instanz der Testklasse; `setup()` und `teardown()` sind optional.
- Kommentare in GDScript beginnen mit `#` oder `##`. Es gibt keine Block-Kommentare mit `"""`.

- `project.godot` nur ändern, wenn das Ticket es ausdrücklich verlangt.
- `.tscn`-Dateien vorsichtig bearbeiten: Jede `ext_resource`-/`sub_resource`-ID muss eindeutig sein und zu ihren Verweisen passen.
- Niemals Tests löschen oder abschwächen, nur damit die Prüfung grün wird.
