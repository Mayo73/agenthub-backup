---
id: T-0378
title: ModuleManifest und ModuleRegistry – Modulvertrag, Abhängigkeiten, Inkompatibles abweisen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Module“ (Lastenheft Muss 2, Abnahmekriterium 5): Module melden Version, Fähigkeiten und Abhängigkeiten über einen gemeinsamen Vertrag; optionale lassen sich an- und abschalten, notwendige sind geschützt, inkompatible werden verständlich abgewiesen.

## Dateien
- `core/module_manifest.gd` – neu, Klasse `ModuleManifest`
- `core/module_registry.gd` – neu, Klasse `ModuleRegistry`
- `tests/test_module_manifest.gd` – neu
- `tests/test_module_registry.gd` – neu

## Akzeptanzkriterien
`class_name ModuleManifest`, `extends RefCounted`:
- `var id := ""`, `var name := ""`, `var version := "0.0.0"`, `var engine_api := 1`, `var requires: Array[String] = []`, `var optional := true`, `var capabilities: Array[String] = []`
- `static func from_dict(d: Dictionary) -> ModuleManifest` (`engine_api` mit `int(...)`, Listen elementweise mit `str(...)`), `func to_dict() -> Dictionary` mit allen Feldern
- `func validate() -> Array[String]`: `"id fehlt"` bei leerer id, `"name fehlt"` bei leerem Namen, `"version muss die Form 1.2.3 haben"` (RegEx `^\d+\.\d+\.\d+$`)

`class_name ModuleRegistry`, `extends RefCounted`:
- `const ENGINE_API := 1`, `var modules: Dictionary = {}` (id → Manifest), `var enabled: Array[String] = []`
- `func add(m: ModuleManifest) -> CommandResult`: Probleme aus `validate()` → `INVALID_ARGUMENT` mit allen Problemen durch „; “ verbunden; `m.engine_api != ENGINE_API` → `INCOMPATIBLE`, `"Modul %s braucht Engine-Schnittstelle %d, vorhanden ist %d"`; sonst aufnehmen (nicht aktiv), `success({"id": m.id})`
- `func enable(id: String) -> CommandResult`: unbekannt → `NOT_FOUND`, `"Modul %s gibt es nicht"`; fehlt eine Abhängigkeit unter `enabled` → `DEPENDENCY`, `"Modul %s braucht zuerst: %s"` (fehlende durch „, “ verbunden); sonst aktivieren, `success({"id": id})`
- `func disable(id: String) -> CommandResult`: `optional == false` → `DEPENDENCY`, `"Modul %s ist notwendig"`; braucht ein aktives Modul es → `DEPENDENCY`, `"Modul %s wird gebraucht von: %s"`; sonst deaktivieren, `success({"id": id})`
- `func is_enabled(id: String) -> bool`, `func list() -> Array[Dictionary]`: je Modul `to_dict()` plus `"enabled": bool`, nach id sortiert

## Tests
- `tests/test_module_manifest.gd`:
  - `test_laden`: Dictionary mit allen Feldern, `engine_api` als 1.0 → `typeof(m.engine_api)` `TYPE_INT`, `requires` gleich
  - `test_pruefen`: leeres Manifest → genau 2 Probleme „id fehlt“ und „name fehlt“; mit id, Name und Version „1.2“ → `["version muss die Form 1.2.3 haben"]`
- `tests/test_module_registry.gd`, Module `physik` (`optional = false`), `ballistik` (`requires = ["physik"]`), `beispiel` (ohne Abhängigkeiten), alle Version „1.0.0“:
  - `test_aufnehmen_und_aktivieren`: alle drei `add` ok; `enable("ballistik")` → „dependency“, Meldung „Modul ballistik braucht zuerst: physik“; `enable("physik")`, dann `enable("ballistik")` ok
  - `test_inkompatibel`: Manifest `neu` mit `engine_api = 2` → „incompatible“, Meldung „Modul neu braucht Engine-Schnittstelle 2, vorhanden ist 1“; `modules.has("neu")` falsch
  - `test_abschalten`: `beispiel` aktivieren und wieder abschalten → ok, `is_enabled("beispiel")` falsch
  - `test_notwendig`: `physik` aktiv, `disable("physik")` → „dependency“, Meldung „Modul physik ist notwendig“
  - `test_gebraucht`: zusätzlich `effekte` mit `requires = ["ballistik"]`; physik, ballistik, effekte aktiv → `disable("ballistik")` Meldung „Modul ballistik wird gebraucht von: effekte“
  - `test_liste`: `list()` ids `["ballistik", "beispiel", "physik"]`, nach `enable("physik")` hat nur physik `enabled` wahr

Review (19.10.2026): selbst fertiggestellt. Der Agent scheiterte 5-mal an untypisierten Arrays (Array statt Array[String]); Code des 5. Versuchs übernommen und repariert, Hub-Engine 24 Tests grün.
