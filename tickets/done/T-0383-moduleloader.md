---
id: T-0383
title: ModuleLoader und Beispielmodul mit Anleitung
project: hub-engine
priority: 4
after: T-0378
---
## Ziel
Meilenstein „Module“ (Lastenheft Muss 2, Abnahmekriterium 5): Module liegen als Ordner mit `manifest.json` unter `modules/`. Ein Lader liest sie ein und meldet sie bei der `ModuleRegistry` (T-0378) an. Dazu ein Beispielmodul und eine kurze Anleitung, wie man ein eigenes Modul anlegt.

## Dateien
- `core/module_loader.gd` – neu, Klasse `ModuleLoader`
- `modules/beispiel/manifest.json` – neu
- `docs/MODULE.md` – neu, Anleitung
- `tests/test_module_loader.gd` – neu

## Akzeptanzkriterien
`class_name ModuleLoader`, `extends RefCounted`, nur statische Funktionen:
- `static func read_manifest(path: String) -> CommandResult`: Datei mit `FileAccess.get_file_as_string(path)` lesen. Fehlt sie (`FileAccess.file_exists` falsch) → `CommandResult.error(CommandResult.NOT_FOUND, "Manifest fehlt: %s" % path)`. Ist der Inhalt kein Dictionary (`JSON.parse_string` liefert etwas anderes) → `INVALID_ARGUMENT`, `"Manifest ist kein gültiges JSON: %s" % path`. Sonst `success({"manifest": ModuleManifest.from_dict(d)})`.
- `static func load_dir(dir_path: String, registry: ModuleRegistry) -> Array[String]`: für jeden Unterordner von `dir_path` (`DirAccess.get_directories_at`, alphabetisch sortiert) `read_manifest(dir_path + "/" + name + "/manifest.json")`, dann `registry.add(manifest)`. Gibt die Meldungen zurück: bei Erfolg `"%s: geladen" % id`, sonst `"%s: %s" % [ordnername, result.message]`.
- `modules/beispiel/manifest.json`: `{"id": "beispiel", "name": "Beispielmodul", "version": "1.0.0", "engine_api": 1, "requires": [], "optional": true, "capabilities": ["beispiel.hallo"]}`
- `docs/MODULE.md` (deutsch, höchstens eine Seite): Aufbau eines Modulordners, alle Felder des Manifests mit Bedeutung, Regeln für `version` (Form 1.2.3) und `engine_api` (derzeit 1), Abhängigkeiten über `requires`, notwendige Module (`optional: false`) lassen sich nicht abschalten, das Beispielmodul als Vorlage.

## Tests
`tests/test_module_loader.gd`; Testordner `user://test_module_loader/` in `setup()` anlegen (`DirAccess.make_dir_recursive_absolute`) und in `teardown()` mit allen Dateien löschen (erst Dateien, dann Ordner, mit `DirAccess.remove_absolute`).
- `test_beispiel_lesen`: `read_manifest("res://modules/beispiel/manifest.json")` → ok, `data["manifest"].id` „beispiel“, `data["manifest"].engine_api` 1
- `test_fehlt`: `read_manifest("user://test_module_loader/gibtsnicht/manifest.json")` → Code „not_found“
- `test_kaputt`: Datei `user://test_module_loader/kaputt/manifest.json` mit Inhalt `{nicht json` → Code „invalid_argument“
- `test_ordner_laden`: im Testordner `a/manifest.json` (id „a“, Version „1.0.0“) und `b/manifest.json` (id „b“, `engine_api` 2) schreiben; `load_dir("user://test_module_loader", registry)` → `["a: geladen", "b: Modul b braucht Engine-Schnittstelle 2, vorhanden ist 1"]`, `registry.modules.has("a")` wahr, `has("b")` falsch
- `test_modulordner`: `load_dir("res://modules", registry)` → enthält „beispiel: geladen“

Review (19.10.2026): nach 5 Fehlversuchen von Claude selbst umgesetzt und committet (verify grün, 303 Tests).
