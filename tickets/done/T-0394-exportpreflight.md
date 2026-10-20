---
id: T-0394
title: ExportPreflight – Voraussetzungen für den Windows-Export vorab prüfen
project: hub-engine
priority: 4
after: T-0379
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 11 „fehlende Voraussetzungen vor dem Build anzeigen“, Abnahmekriterium 15): Vor einem Export wird geprüft, ob die Godot-Exportvorlagen da sind, der Zielpfad erlaubt ist und die Zieldatei passt. Alle Probleme werden auf einmal und verständlich gemeldet. Reine Logik; der Vorlagen-Ordner wird übergeben, Tests nutzen einen eigenen.

## Dateien
- `core/export_preflight.gd` – neu, Klasse `ExportPreflight`
- `tests/test_export_preflight.gd` – neu

## Akzeptanzkriterien
`class_name ExportPreflight`, `extends RefCounted`. Nutzt `PathGuard` (T-0379, `core/path_guard.gd`) und `CommandResult`.
- `const TEMPLATE_FILES: Array[String] = ["windows_release_x86_64.exe", "windows_debug_x86_64.exe"]`
- `var guard: PathGuard`, `var templates_dir: String`
- `func _init(path_guard: PathGuard, templates: String) -> void`
- `static func default_templates_dir() -> String`: `OS.get_data_dir().path_join("Godot/export_templates")` und darunter die Version aus `Engine.get_version_info()` als `"%d.%d.%d.%s" % [major, minor, patch, status]` (Typen ausdrücklich: `var info: Dictionary = Engine.get_version_info()`, `var major: int = info["major"]` usw.)
- `func problems(output_path: String) -> Array[String]`, sammelt in dieser Reihenfolge:
  - je fehlender Datei aus `TEMPLATE_FILES` in `templates_dir` (`FileAccess.file_exists(templates_dir.path_join(datei))`): `"Exportvorlage fehlt: %s"` (Dateiname)
  - Zielpfad nicht erlaubt (`guard.is_allowed(output_path)` falsch): `"Zielpfad ist nicht erlaubt: %s"` mit `PathGuard.normalize(output_path)`
  - Endung nicht `exe` (`output_path.get_extension().to_lower()`): „Die Zieldatei muss auf .exe enden“
- `func check(output_path: String) -> CommandResult`: keine Probleme → `success({"output": PathGuard.normalize(output_path)})`; sonst `CommandResult.error(CommandResult.DEPENDENCY, "Export nicht möglich")` und danach `result.data = {"problems": liste}`

## Tests
`tests/test_export_preflight.gd`:
- `setup()`: Ordner `user://test_export_preflight/vorlagen` anlegen (`DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(...))`), `guard = PathGuard.new()`, `guard.add_root(ProjectSettings.globalize_path("user://test_export_preflight/ausgabe"))`, `pre = ExportPreflight.new(guard, ProjectSettings.globalize_path("user://test_export_preflight/vorlagen"))`, `ziel = ProjectSettings.globalize_path("user://test_export_preflight/ausgabe/spiel.exe")`.
- `teardown()`: beide Vorlagen-Dateien und die Ordner `vorlagen` und `test_export_preflight` mit `DirAccess.remove_absolute` löschen.
- Hilfsmethode `_vorlagen_anlegen()`: schreibt beide Dateien aus `TEMPLATE_FILES` (Inhalt „x“).
- `test_alles_da`: `_vorlagen_anlegen()`, `check(ziel)` ok, `data["output"]` gleich `PathGuard.normalize(ziel)`
- `test_vorlagen_fehlen`: ohne Vorlagen → `problems(ziel)` gleich `["Exportvorlage fehlt: windows_release_x86_64.exe", "Exportvorlage fehlt: windows_debug_x86_64.exe"]`
- `test_pfad_verboten`: `_vorlagen_anlegen()`, `problems("C:/Windows/spiel.exe")` gleich `["Zielpfad ist nicht erlaubt: c:/Windows/spiel.exe"]`
- `test_endung`: `_vorlagen_anlegen()`, Ziel `spiel.txt` im erlaubten Ordner → `["Die Zieldatei muss auf .exe enden"]`
- `test_ergebnis_fehler`: ohne Vorlagen `check(ziel)` → Code „dependency“, `data["problems"].size()` 2
- `test_standardordner`: `default_templates_dir()` enthält „export_templates“ und endet auf `str(Engine.get_version_info()["status"])`

Review (19.10.2026): gemergt.
