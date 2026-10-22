---
id: T-0566
title: EditorClipboard – Objekte kopieren und einfügen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Editor: Objekte duplizieren): Ausgewählte Objekte samt Unterobjekten kopieren und als neue Objekte mit neuen Kennungen einfügen.

## Dateien
- `core/editor_clipboard.gd` – neu, Klasse `EditorClipboard`
- `tests/test_editor_clipboard.gd` – neu

## Akzeptanzkriterien
`class_name EditorClipboard`, `extends RefCounted`. Vorher `core/scene_model.gd` lesen (`add_object`, `get_object`, `children`, `has_object`).
- `var items: Array[Dictionary] = []`, je `{"key": String, "type": String, "parent_key": String, "props": Dictionary}` (`key` = Kennung beim Kopieren, `parent_key` = "" bei den kopierten Wurzeln)
- `func copy(model: SceneModel, ids: Array[String]) -> int`: `items` leeren; für jede vorhandene Kennung das Objekt und rekursiv alle Unterobjekte (`children`) aufnehmen, Eltern immer vor Kindern; schon aufgenommene Kennungen nicht doppelt; Rückgabe: Anzahl der Einträge
- `func paste(model: SceneModel, parent_id: String = "") -> Array[String]`: Einträge der Reihe nach mit `model.add_object(type, neuer_eltern, props.duplicate(true))` anlegen; `neuer_eltern` ist `parent_id` für Wurzeln, sonst die neue Kennung des Elterneintrags; Rückgabe: die neuen Kennungen der Wurzeln. Leere Zwischenablage oder `parent_id` nicht leer und nicht vorhanden → `[]`
- `func is_empty() -> bool`
- Mehrfaches Einfügen erzeugt jedes Mal neue Objekte

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Werte aus Dictionaries immer mit Typ lesen (`var obj: Dictionary = model.get_object(id)`, `var t: String = obj["type"]`), Kennungen in `var ids: Array[String] = []` sammeln. Einrückung nur mit Tabs.

## Tests
`tests/test_editor_clipboard.gd` (in `setup()`: `model = SceneModel.new()`, `kiste = model.add_object("Node2D", "", {"name": "Kiste"})`, `sprite = model.add_object("Sprite2D", kiste, {"textur": "kiste.png"})`, `clip = EditorClipboard.new()`):
- `test_kopieren`: `clip.copy(model, [kiste])` ist 2
- `test_einfuegen`: nach `copy`: `paste(model)` liefert 1 Kennung, ungleich `kiste`; deren `model.children(...)` hat 1 Eintrag, dessen `props["textur"]` „kiste.png“ ist; `model.objects.size()` ist 4
- `test_zweimal`: zweimal `paste` → `model.objects.size()` 6
- `test_kind_doppelt`: `clip.copy(model, [kiste, sprite])` ist 2
- `test_leer`: neue Zwischenablage → `is_empty()` true, `paste(model)` leer; nach `copy` ist `paste(model, "o999")` leer

Review (21.10.2026): gemergt.
