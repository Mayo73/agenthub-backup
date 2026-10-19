---
id: T-0399
title: PhysicsSettings – Physikparameter prüfen, speichern und per Befehl ändern
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Durchstich“ (Lastenheft Muss 5: „einstellbare Physikparameter über Oberfläche und Agentenschnittstelle“): Die Projekt-Physikwerte liegen in einem prüfbaren Modell und lassen sich per Befehl lesen und ändern.

## Dateien
- `core/physics_settings.gd` – neu, Klasse `PhysicsSettings`
- `tests/test_physics_settings.gd` – neu

## Akzeptanzkriterien
`class_name PhysicsSettings`, `extends RefCounted`:
- `var gravity := 9.81`, `var hz := 120`, `var friction := 0.5`, `var bounce := 0.0`, `var layer_names: Array[String] = ["Welt", "Spieler", "Gegner", "Projektile"]`
- `func to_dict() -> Dictionary` mit allen Feldern; `static func from_dict(d: Dictionary) -> PhysicsSettings` (`hz` mit `int(...)`, Zahlen mit `float(...)`, `layer_names` elementweise mit `str(...)` per `append`, fehlende Felder behalten den Standard)
- `func validate() -> Array[String]` (Reihenfolge so): `"gravity muss zwischen 0 und 100 liegen"`, `"hz muss zwischen 30 und 480 liegen"`, `"friction muss zwischen 0 und 1 liegen"`, `"bounce muss zwischen 0 und 1 liegen"`, `"höchstens 32 Kollisionsebenen"`
- `func apply(changes: Dictionary) -> CommandResult`: unbekannte Schlüssel (nicht in `to_dict()`) → `INVALID_ARGUMENT` `"Unbekannte Einstellung: %s"`; dann Kopie über `from_dict(to_dict().merged(changes, true))` bauen; hat die Kopie Probleme → `INVALID_ARGUMENT` mit Problemen durch „; “ verbunden, nichts übernehmen; sonst Werte der Kopie übernehmen und `success(to_dict())`
- `static func register_commands(commands: CommandRegistry, settings: PhysicsSettings) -> void`: `"physics.get"` (Parameter `{}`, `success(settings.to_dict())`) und `"physics.set"` (Parameter `{"changes": "dict"}`, Ergebnis von `settings.apply(...)`)

## Tests
`tests/test_physics_settings.gd`:
- `test_standard`: neue Instanz → `validate()` leer, `hz` 120
- `test_laden`: `from_dict({"hz": 60.0, "gravity": 3})` → `typeof(hz)` `TYPE_INT`, `hz` 60, `gravity` 3.0, `friction` 0.5
- `test_ungueltig`: `apply({"bounce": 2.0})` → „invalid_argument“, `bounce` bleibt 0.0
- `test_unbekannt`: `apply({"wind": 1})` → Meldung „Unbekannte Einstellung: wind“
- `test_befehle`: Registry, `register_commands`; `execute("physics.set", {"changes": {"gravity": 1.62}})` ok; `execute("physics.get", {}).data["gravity"]` 1.62

Review (19.10.2026): gemergt, nachgebessert: Docstrings ersetzt, test_befehle registrierte die Befehle doppelt, Meldung in test_unbekannt jetzt exakt geprüft.
