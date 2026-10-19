---
id: T-0393
title: EditorSession – Auswahl und Suche im Szenenbaum
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 3 „sichtbare Auswahl, Suchfunktion“): Auswahl und Suche des Editors als reine Logik, damit GUI und Agenten dieselbe Auswahl sehen und dieselbe Suche benutzen.

## Dateien
- `core/editor_session.gd` – neu, Klasse `EditorSession`
- `tests/test_editor_session.gd` – neu

## Akzeptanzkriterien
`class_name EditorSession`, `extends RefCounted`. Nutzt `SceneModel` (`core/scene_model.gd`).
- `signal selection_changed(id: String)`
- `var model: SceneModel`, `var selected := ""`
- `func _init(scene: SceneModel) -> void`
- `func select(id: String) -> bool`: `""` hebt die Auswahl auf (wahr). Unbekannte Kennung → `false`, Auswahl bleibt. Sonst `selected = id`. Das Signal kommt nur, wenn sich `selected` wirklich ändert.
- `func selected_object() -> Dictionary`: `model.get_object(selected)` oder `{}` ohne Auswahl
- `func validate() -> void`: gibt es das ausgewählte Objekt nicht mehr (z. B. nach Löschen), wird die Auswahl aufgehoben (mit Signal)
- `func path_of(id: String) -> Array[String]`: Kennungen von der obersten Ebene bis einschließlich `id` (über `parent`), unbekannt → `[]`
- `func search(text: String) -> Array[String]`: Kennungen in Reihenfolge von `model.order`, bei denen der Text ohne Groß-/Kleinschreibung (`findn`) in der Kennung, im Typ oder in der Eigenschaft `name` (falls vorhanden, als `str(...)`) vorkommt. Leerer Text (nach `strip_edges()`) → `[]`

## Tests
`tests/test_editor_session.gd`, in `setup()` ein Modell: `Node2D` `{"name": "Welt"}` (o1), darunter `Sprite2D` `{"name": "Spieler"}` (o2) und `Camera2D` `{"name": "Kamera"}` (o3); `session = EditorSession.new(model)`. Signal mit einer Methode der Testklasse zählen (`var signal_count := 0`, in `setup()` auf 0, `session.selection_changed.connect(_on_changed)`; ein Lambda zählt nicht, weil es lokale Variablen nur kopiert):
- `test_auswahl`: `select("o2")` wahr → `selected` „o2“, `selected_object()["type"]` „Sprite2D“, `signal_count` 1; nochmal `select("o2")` → `signal_count` bleibt 1
- `test_unbekannt`: `select("o2")`, `select("o9")` falsch → `selected` weiter „o2“
- `test_aufheben`: `select("o2")`, `select("")` wahr → `selected` „“, `selected_object()` leer
- `test_nach_loeschen`: `select("o2")`, `model.remove_object("o2")`, `validate()` → `selected` „“, `signal_count` 2
- `test_pfad`: `path_of("o3")` `["o1", "o3"]`; `path_of("o1")` `["o1"]`; `path_of("o9")` `[]`
- `test_suche`: `search("spiel")` `["o2"]`; `search("2D")` `["o1", "o2", "o3"]`; `search("o3")` `["o3"]`; `search("  ")` `[]`
