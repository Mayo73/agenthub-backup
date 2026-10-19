# Hub Engine – Regeln für Agents

Modulare Windows-Spielengine auf Basis von **Godot 4.7** (GDScript) für 2D- und 3D-Spiele. Renderer, Physik und Export kommen aus Godot; die Hub Engine baut darüber ein gemeinsames Befehlsmodell für GUI, CLI und KI-Agenten, ein Projekt- und Szenenmodell mit Revisionen, Module, Ballistik und Testwerkzeuge. Die Oberfläche ist deutsch. Mehr in `docs/ARCHITEKTUR.md`.

## Architektur (wichtig)

- **Kern in `core/`:** reine Logik, `extends RefCounted`, ohne Nodes und ohne Szenenbaum. Jede Klasse hat ein `class_name`. Alles, was die Oberfläche kann, muss auch über den Kern gehen.
- **Ergebnisse** von Befehlen sind immer `CommandResult` (`core/command_result.gd`): `CommandResult.success(data, text)` oder `CommandResult.error(CommandResult.NOT_FOUND, "…")`. Fehlercodes nur aus den Konstanten dort.
- **Daten** sind JSON-fähig: `to_dict()` und `static func from_dict(d: Dictionary)`. Zahlen aus JSON kommen als `float` zurück, deshalb ganze Zahlen mit `int(...)` lesen.
- **Physik:** 120 Physikschritte pro Sekunde (`project.godot`). Szeneneinheiten: 1 Einheit = 1 Meter, Schwerkraft 9,81 Einheiten/s² nach unten (2D: +y, 3D: −y).
- Oberfläche (`scripts/`, `extends Control`) zeigt nur an und ruft den Kern auf.

## Dateien

| Pfad | Aufgabe |
|---|---|
| `core/command_result.gd` | `CommandResult`: Ergebnis mit `code`, `message`, `data` |
| `scripts/main.gd` | `Main`: Startbildschirm (`title_label`, `info_label`) |
| `scenes/main.tscn` | einzige Szene, startet `Main` |
| `docs/ARCHITEKTUR.md` | Module, Befehlsmodell, Fehlercodes, Abgrenzung zu Godot |

## Regeln

- GDScript 4 mit statischen Typen (`var x: int`, `func f() -> void`). Typen bei Werten aus Dictionaries ausdrücklich angeben (`var n: int = d.get("n", 0)`), sonst bricht die Prüfung mit „inferred from a Variant“ ab.
- Keine Konstanten mit globalen Namen wie `OK`, `FAILED`, `ERR_…`.
- Einrückung **nur mit Tabs**, niemals mit Leerzeichen.
- Kommentare beginnen mit `#` oder `##`. Es gibt keine Block-Kommentare mit `"""`.
- Zu jeder neuen Logik gehört ein Test in `tests/test_<thema>.gd`:

  ```gdscript
  extends "res://tests/base_test.gd"

  var model: SceneModel

  func setup() -> void:          # optional, läuft vor jedem Test
  	model = SceneModel.new()

  func test_beschreibung() -> void:
  	check_eq(ist_wert, soll_wert, "was geprüft wird")   # Zahlen vergleicht check_eq ungefähr
  	check(bedingung, "was geprüft wird")
  ```
- Tests, die Dateien schreiben, nutzen `user://test_<thema>/…` und räumen in `teardown()` auf.
- Bestehende Tests nicht löschen, umbenennen oder abschwächen.
- Nicht ändern: `verify.cmd`, `tests/run_tests.gd`, `tests/base_test.gd`, `playtests/playtest.gd`.
- Keine Netzwerkzugriffe, keine Plugins aus dem Internet, keine externen Medien.

## Prüfen

`verify.cmd` lädt alle Skripte, startet `scenes/main.tscn` kurz und führt alle `test_*`-Methoden aus. Bestanden nur bei `ERGEBNIS: <n> ok, 0 fehlgeschlagen`.

Spieltests in `playtests/` führt der Hub aus (`hub\tools\spieltest.ps1 -Projekt hub-engine`), nicht `verify.cmd`.
