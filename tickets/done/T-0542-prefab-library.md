---
id: T-0542
title: PrefabLibrary – Vorlagen verwalten und Objekte daraus erzeugen
project: hub-engine
priority: 4
after: T-0541
---
## Ziel
Muss 4: Objektvorlagen im Projekt sammeln und daraus Objekte mit stabilen, fortlaufenden Kennungen erzeugen. Grundlage für Editor-Befehle und Agenten.

## Dateien
- `core/prefab_library.gd` – neu, Klasse `PrefabLibrary`
- `tests/test_prefab_library.gd` – neu

## Akzeptanzkriterien
`class_name PrefabLibrary`, `extends RefCounted`. Vorher `core/prefab.gd` und `core/command_result.gd` lesen.
- `var prefabs: Dictionary = {}` (Kennung → `Prefab`), `var counters: Dictionary = {}` (Kennung → int)
- `func add(prefab: Prefab) -> CommandResult`: leere `id` → `CommandResult.error(CommandResult.INVALID_ARGUMENT, "Vorlage braucht eine Kennung")`; schon vorhanden → `CommandResult.error(CommandResult.CONFLICT, "Vorlage %s gibt es schon" % prefab.id)`; sonst speichern, `CommandResult.success({"id": prefab.id})`
- `func get_prefab(prefab_id: String) -> Prefab`: Vorlage oder `null`
- `func spawn(prefab_id: String, overrides: Dictionary = {}) -> CommandResult`: unbekannt → `CommandResult.error(CommandResult.NOT_FOUND, "Vorlage %s gibt es nicht" % prefab_id)`; sonst Zähler um 1 erhöhen, Kennung `"%s-%d" % [prefab_id, zaehler]`, `CommandResult.success({"object": prefab.instantiate(kennung, overrides)})`
- `func ids() -> Array[String]`: alle Kennungen sortiert
- `func to_dict() -> Dictionary`: `{"prefabs": [to_dict() je Vorlage, nach Kennung sortiert], "counters": counters.duplicate()}`; `static func from_dict(d: Dictionary) -> PrefabLibrary` (Zähler mit `int(...)`)

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var n: int = int(counters.get(prefab_id, 0))`), typisierte Arrays mit `var a: Array[String] = []` anlegen.

## Tests
`tests/test_prefab_library.gd`, `setup()`: `lib = PrefabLibrary.new()`, `lib.add(Prefab.new("kiste", "RigidBody2D", {"mass": 2.0}))`:
- `test_anlegen`: nochmal `Prefab.new("kiste")` → Code `CommandResult.CONFLICT`; `lib.add(Prefab.new(""))` → `CommandResult.INVALID_ARGUMENT`
- `test_erzeugen`: zwei `spawn("kiste")` → `data.object.id` „kiste-1“ und „kiste-2“; `spawn("fass")` → `CommandResult.NOT_FOUND`
- `test_ueberschreiben`: `spawn("kiste", {"mass": 5.0})` → `data.object.props.mass` 5.0
- `test_speichern`: nach zwei `spawn` liefert `PrefabLibrary.from_dict(lib.to_dict())` beim nächsten `spawn("kiste")` „kiste-3“, `ids()` ist `["kiste"]`

Review (21.10.2026): gemergt, nachgebessert: eigene Kopien der CommandResult-Codes entfernt, nutzt jetzt CommandResult.*.
