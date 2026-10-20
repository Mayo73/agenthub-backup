---
id: T-0423
title: ProviderRegistry – austauschbare KI-Anbieter mit ehrlicher Meldung bei fehlendem Anbieter
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: austauschbare Provideradapter, fehlenden Provider verständlich anzeigen, keine simulierte KI-Erfolgsmeldung; Abnahmekriterium 12): Ein Verzeichnis der KI-Anbieter mit Zustand und Auswahl. Die Erreichbarkeit setzt später ein Adapter; hier nur die Logik.

## Dateien
- `core/provider_registry.gd` – neu, Klasse `ProviderRegistry`
- `tests/test_provider_registry.gd` – neu

## Akzeptanzkriterien
`class_name ProviderRegistry`, `extends RefCounted`:
- `var providers: Dictionary = {}` (Kennung → `{"id": String, "name": String, "kind": String, "available": bool, "priority": int}`), `var preferred := ""`
- `kind` ist `"lokal"` oder `"hub"`
- `func add(id: String, name: String, kind: String, priority: int = 5) -> CommandResult`: `kind` nicht erlaubt → `INVALID_ARGUMENT`, `"Art %s ist unbekannt"`; Kennung schon vorhanden → `CONFLICT`, `"Anbieter %s gibt es schon"`; sonst `available = false`, `success({"id": id})`
- `func set_available(id: String, available: bool) -> bool`
- `func prefer(id: String) -> CommandResult`: unbekannt → `NOT_FOUND`, `"Anbieter %s gibt es nicht"`; sonst `preferred = id`, `success`
- `func active() -> CommandResult`: ist `preferred` gesetzt und erreichbar → dieser. Sonst der erreichbare mit kleinster `priority` (bei Gleichstand kleinste Kennung). Keiner erreichbar → `CommandResult.error(CommandResult.DEPENDENCY, "Kein KI-Anbieter erreichbar. Manuelles Bearbeiten, Speichern, Spielen und Export funktionieren weiter.")`. Erfolg: `success({"id": id, "name": name})`
- `func status_text() -> String`: je Anbieter (Kennungen sortiert) `"%s: erreichbar"` bzw. `"%s: nicht erreichbar"` mit dem Namen, Zeilen mit `"\n"` verbunden; ohne Anbieter „Keine KI-Anbieter eingerichtet“

## Tests
`tests/test_provider_registry.gd`, `setup()`: `reg = ProviderRegistry.new()`, `reg.add("ollama", "Ollama", "lokal", 1)`, `reg.add("claude", "Claude", "hub", 2)`:
- `test_keiner`: `active()` → `code` „dependency“, Meldung beginnt mit „Kein KI-Anbieter erreichbar“
- `test_prioritaet`: beide erreichbar → `active().data["id"]` „ollama“
- `test_bevorzugt`: beide erreichbar, `prefer("claude")` → „claude“; `set_available("claude", false)` → „ollama“
- `test_fehler`: `add("x", "X", "cloud")` → „invalid_argument“; `add("ollama", "O", "lokal")` → „conflict“; `prefer("gibts")` → „not_found“
- `test_text`: nur „ollama“ erreichbar → `status_text()` ist „Claude: nicht erreichbar\nOllama: erreichbar“

Review (19.10.2026): gemergt.
