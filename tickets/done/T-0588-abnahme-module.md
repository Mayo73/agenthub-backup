---
id: T-0588
title: Abnahmetest Kriterium 5 – Module einbinden, deaktivieren, abweisen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 5: Das Beispielmodul lässt sich einbinden und wieder deaktivieren, ein inkompatibles Modul wird verständlich abgewiesen, Bestehendes bleibt nutzbar. Nur ein neuer Test, keine Änderung am Kern.

## Dateien
- `tests/test_abnahme_module.gd` – neu

## Akzeptanzkriterien
Vorher `core/module_manifest.gd`, `core/module_registry.gd` und `core/command_result.gd` lesen. Im Test eine Hilfsfunktion `func _modul(id: String, api: int, reqs: Array[String] = []) -> ModuleManifest`: `ModuleManifest.new()`, `id = id`, `name = id.capitalize()`, `version = "1.0.0"`, `engine_api = api`, `requires = reqs`. In `setup()`: `reg = ModuleRegistry.new()`.

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var r: CommandResult = …`).

## Tests
`tests/test_abnahme_module.gd`:
- `test_einbinden`: `reg.add(_modul("beispiel", 1)).code` „ok“, `reg.enable("beispiel").code` „ok“, `is_enabled("beispiel")` wahr; `reg.disable("beispiel").code` „ok“, `is_enabled("beispiel")` falsch
- `test_inkompatibel`: `var r: CommandResult = reg.add(_modul("alt", 2))` hat Code „incompatible“, `r.message` enthält „Engine-Schnittstelle“; `reg.modules.has("alt")` falsch; `reg.enable("alt").code` „not_found“
- `test_bestehende_bleiben`: „beispiel“ hinzufügen und aktivieren, dann `_modul("alt", 2)` hinzufügen (wird abgewiesen) → `is_enabled("beispiel")` weiter wahr, `reg.list().size()` ist 1
- `test_abhaengigkeit`: „beispiel“ und `_modul("zusatz", 1, ["beispiel"])` hinzufügen; `enable("zusatz")` hat Code „dependency“ und die Meldung enthält „beispiel“; nach `enable("beispiel")` ist `enable("zusatz").code` „ok“; dann hat `disable("beispiel")` Code „dependency“ und die Meldung enthält „zusatz“
- `test_ungueltige_version`: Manifest mit `version = "1.0"` → `add(...).code` „invalid_argument“

Review (21.10.2026): gemergt.
