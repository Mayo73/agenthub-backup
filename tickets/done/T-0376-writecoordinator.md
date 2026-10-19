---
id: T-0376
title: WriteCoordinator – Revisionen und Konflikterkennung ohne stille Überschreibungen
project: hub-engine
priority: 4
after: T-0373
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Lastenheft Muss 8, Abnahmekriterium 10): Mensch und Agenten ändern dasselbe Modell. Wer auf einem veralteten Stand dieselbe Eigenschaft ändert, bekommt einen Konflikt statt einer stillen Überschreibung.

## Dateien
- `core/write_coordinator.gd` – neu, Klasse `WriteCoordinator`
- `tests/test_write_coordinator.gd` – neu

## Akzeptanzkriterien
`class_name WriteCoordinator`, `extends RefCounted`:
- `var model: SceneModel`, `var revision := 0`, `var entries: Array[Dictionary] = []`
- `func _init(scene: SceneModel) -> void`
- `func set_property(id: String, key: String, value: Variant, base_revision: int, author: String) -> CommandResult`:
  - Objekt fehlt → `NOT_FOUND`, `"Objekt %s gibt es nicht"`
  - gibt es einen Eintrag mit `revision > base_revision` für dasselbe `id` **und** `key` → `CONFLICT`, Meldung `"Konflikt: %s.%s wurde in Revision %d von %s geändert"` (id, key, Revision und Autor des neuesten solchen Eintrags), `data` `{"current": aktueller Wert, "revision": revision}`; das Modell bleibt unverändert
  - sonst: Wert setzen, `revision += 1`, Eintrag `{"revision", "author", "id", "key", "old", "new"}` anhängen, `success({"revision": revision})`
- Änderungen an **anderen** Eigenschaften seit `base_revision` sind kein Konflikt.
- `func history(id: String) -> Array[Dictionary]`: Einträge dieses Objekts in Reihenfolge

## Tests
`tests/test_write_coordinator.gd`, in `setup()` `model = SceneModel.new()`, `id = model.add_object("RigidBody2D", "", {"mass": 1.0, "friction": 0.5})`, `wc = WriteCoordinator.new(model)`:
- `test_aendern`: `set_property(id, "mass", 2.0, 0, "gui")` → ok, `data["revision"]` 1, `model.get_property(id, "mass")` 2.0
- `test_konflikt`: als „gui“ `mass` 2.0 auf Basis 0, dann als „agent“ `mass` 3.0 auf Basis 0 → Code „conflict“, Meldung „Konflikt: o1.mass wurde in Revision 1 von gui geändert“, `data["current"]` 2.0, Modell weiter 2.0
- `test_kein_konflikt_andere_eigenschaft`: „gui“ ändert `mass` auf Basis 0, „agent“ ändert `friction` auf Basis 0 → ok, `revision` 2
- `test_aktuelle_basis`: „gui“ ändert `mass` (Revision 1), „agent“ ändert `mass` auf Basis 1 → ok
- `test_fehlt`: `set_property("o9", "mass", 1.0, 0, "gui")` → „not_found“, `revision` 0
- `test_verlauf`: zwei Änderungen → `history(id).size()` 2, erster Eintrag `old` 1.0, `new` 2.0, `author` „gui“

Review (19.10.2026): gemergt, nachgebessert: Konfliktmeldung nennt jetzt den neuesten Eintrag, data.revision ist die aktuelle Revision; Test test_neuester_konflikt ergänzt.
