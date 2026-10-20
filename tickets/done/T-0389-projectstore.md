---
id: T-0389
title: ProjectStore – Projekt öffnen und speichern, nur in erlaubten Pfaden
project: hub-engine
priority: 4
after: T-0373, T-0379
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Abnahmekriterium 4 „Projekt öffnen, Objekt ändern, speichern“): Ein Projekt (Name, Szene, aktive Module) wird als JSON gespeichert und wieder geladen. Geschrieben und gelesen wird nur innerhalb der erlaubten Orte (`PathGuard`, T-0379).

## Dateien
- `core/project_store.gd` – neu, Klasse `ProjectStore`
- `tests/test_project_store.gd` – neu

## Akzeptanzkriterien
`class_name ProjectStore`, `extends RefCounted`:
- `const FORMAT := 1`
- `var guard: PathGuard`, `func _init(path_guard: PathGuard) -> void`
- `func save(path: String, name: String, scene: SceneModel, modules: Array[String]) -> CommandResult`:
  - `guard.check(path)` nicht ok → dieses Ergebnis zurückgeben (Code „forbidden_path“), nichts schreiben
  - Inhalt `{"format": FORMAT, "name": name, "scene": scene.to_dict(), "modules": modules}` mit `JSON.stringify(inhalt, "\t")` schreiben (`FileAccess.open(..., FileAccess.WRITE)`); Ordner vorher mit `DirAccess.make_dir_recursive_absolute(path.get_base_dir())` anlegen
  - Datei lässt sich nicht öffnen → `EXEC_FAILED`, `"Speichern fehlgeschlagen: %s"`
  - sonst `success({"path": path})`
- `func open(path: String) -> CommandResult`:
  - `guard.check(path)` nicht ok → dieses Ergebnis
  - Datei fehlt → `NOT_FOUND`, `"Projekt fehlt: %s"`
  - kein Dictionary → `INVALID_ARGUMENT`, `"Projektdatei ist beschädigt: %s"`
  - `int(d.get("format", 0)) != FORMAT` → `INCOMPATIBLE`, `"Projektformat %d wird nicht unterstützt" % format`
  - sonst `success({"name": String, "scene": SceneModel.from_dict(d["scene"]), "modules": Array[String]})` (Module elementweise mit `str(...)`)

## Tests
`tests/test_project_store.gd`, in `setup()`: `guard = PathGuard.new()`, `guard.add_root("user://test_project_store")`, `store = ProjectStore.new(guard)`; `teardown()` löscht `user://test_project_store/demo/projekt.json` und die Ordner `demo` und `test_project_store`.
- `test_speichern_und_oeffnen`: Szene mit zwei Objekten (eins mit `{"mass": 2.0}`), `save("user://test_project_store/demo/projekt.json", "Demo", scene, ["physik"])` ok; `open(...)` → ok, `data["name"]` „Demo“, `data["scene"].order.size()` 2, `data["scene"].get_property("o1", "mass")` 2.0, `data["modules"]` `["physik"]`
- `test_verboten`: `save("user://anderswo/p.json", ...)` → Code „forbidden_path“, `FileAccess.file_exists("user://anderswo/p.json")` falsch
- `test_fehlt`: `open("user://test_project_store/gibtsnicht.json")` → „not_found“
- `test_format`: Datei mit `{"format": 99, "name": "x", "scene": {}, "modules": []}` selbst schreiben → `open` Code „incompatible“, Meldung „Projektformat 99 wird nicht unterstützt“
- `test_kaputt`: Datei mit Inhalt `kaputt` → „invalid_argument“

Review (19.10.2026): gemergt, nachgebessert: gibt das Ergebnis von PathGuard zurück, JSON-Typ sicher geprüft.
