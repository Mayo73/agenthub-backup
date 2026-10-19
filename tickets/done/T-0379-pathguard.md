---
id: T-0379
title: PathGuard – Änderungen und Exporte nur an erlaubten Orten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Abnahmekriterium 15): Speichern und Export schreiben nur in erlaubte Projekt- und Ausgabeordner. Ein unzulässiger Zielpfad scheitert verständlich.

## Dateien
- `core/path_guard.gd` – neu, Klasse `PathGuard`
- `tests/test_path_guard.gd` – neu

## Akzeptanzkriterien
`class_name PathGuard`, `extends RefCounted`:
- `var roots: Array[String] = []`
- `static func normalize(path: String) -> String`: `\` durch `/` ersetzen, dann `simplify_path()`; ist das zweite Zeichen `:` (Laufwerk), den ersten Buchstaben klein schreiben (nur ihn); ein abschließendes `/` entfernen, außer der Pfad endet auf `://`
- `func add_root(path: String) -> void`: speichert `normalize(path)`
- `func is_allowed(path: String) -> bool`: `normalize(path)` ist gleich einer Wurzel oder beginnt mit Wurzel + `"/"`. Kein Präfix-Trick: Wurzel `c:/Spiele/demo` erlaubt **nicht** `c:/Spiele/demo2`.
- `func check(path: String) -> CommandResult`: erlaubt → `success({"path": normalize(path)})`; sonst `FORBIDDEN_PATH`, `"Pfad liegt außerhalb der erlaubten Orte: %s"` mit dem normalisierten Pfad

## Tests
`tests/test_path_guard.gd`, in `setup()` `guard = PathGuard.new()`, `guard.add_root("C:\\Spiele\\demo")`, `guard.add_root("user://exporte")`:
- `test_normalisieren`: `normalize("C:\\Spiele\\demo\\..\\demo\\szene.json")` ist „c:/Spiele/demo/szene.json“; `normalize("C:/Spiele/demo/")` ist „c:/Spiele/demo“
- `test_erlaubt`: `is_allowed("C:/Spiele/demo/szenen/a.json")`, `is_allowed("C:/Spiele/demo")` und `is_allowed("user://exporte/spiel.exe")` wahr
- `test_ausbruch`: `is_allowed("C:/Spiele/demo/../../Windows/x.dll")` falsch
- `test_praefix`: `is_allowed("C:/Spiele/demo2/a.json")` falsch
- `test_pruefen`: `check("D:/fremd/a.txt")` → Code „forbidden_path“, Meldung „Pfad liegt außerhalb der erlaubten Orte: d:/fremd/a.txt“; `check("C:/Spiele/demo/a.txt").data["path"]` „c:/Spiele/demo/a.txt“

Review (19.10.2026): gemergt, nachgebessert: Eigene simplify_path-Funktion machte aus user:// ein user:/; jetzt String.simplify_path(), Test test_user_pfad ergänzt.
