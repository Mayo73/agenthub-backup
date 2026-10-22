---
id: T-0569
title: Abnahmetest Kriterium 12 – Arbeiten ohne KI-Anbieter
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 12: Bei abgeschaltetem KI-Anbieter funktionieren manuelles Bearbeiten und Speichern weiter, und der Assistent meldet den fehlenden Anbieter verständlich. Nur ein neuer Test.

## Dateien
- `tests/test_abnahme_ohne_ki.gd` – neu

## Akzeptanzkriterien
Vorher `core/provider_registry.gd`, `core/scene_model.gd` und `core/undo_stack.gd` lesen.

Hinweis Typen: Test erbt von `res://tests/base_test.gd` und nutzt `check`/`check_eq`. Ergebnisse typisiert (`var r: CommandResult = reg.active()`, `var d: Dictionary = JSON.parse_string(...)`). Einrückung nur mit Tabs.

## Tests
`tests/test_abnahme_ohne_ki.gd` (in `setup()`: `reg = ProviderRegistry.new()`, `reg.add("ollama", "Ollama", ProviderRegistry.KIND_LOKAL, 1)`, `reg.add("claude", "Claude", ProviderRegistry.KIND_HUB, 2)`, beide mit `set_available(…, false)`):
- `test_meldung`: `reg.active().code` ist „dependency“, die Meldung enthält „Kein KI-Anbieter erreichbar“ und „Manuelles Bearbeiten“
- `test_status`: `reg.status_text().count("nicht erreichbar")` ist 2
- `test_bearbeiten_geht`: ohne Anbieter: `SceneModel` anlegen, Objekt hinzufügen, `UndoStack.record()`, `set_property(id, "x", 3.0)` true, `undo()` true, Wert danach nicht 3.0
- `test_speichern_geht`: Objekt mit `x` 3.0; `JSON.parse_string(JSON.stringify(model.to_dict()))` an `SceneModel.from_dict` → `get_property(id, "x")` ist 3.0
- `test_wieder_da`: `reg.set_available("ollama", true)` → `active().code` „ok“, `data["id"]` „ollama“

Review (21.10.2026): gemergt.
