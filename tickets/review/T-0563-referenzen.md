---
id: T-0563
title: ReferenceIndex – Verweise zwischen Objekten und verwaiste Referenzen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Referenzen und stabile Objektkennungen): Merken, welches Objekt über welche Eigenschaft auf welches andere verweist, damit Löschen und Umbenennen keine kaputten Verweise hinterlassen.

## Dateien
- `core/reference_index.gd` – neu, Klasse `ReferenceIndex`
- `tests/test_reference_index.gd` – neu

## Akzeptanzkriterien
`class_name ReferenceIndex`, `extends RefCounted`.
- `var refs: Array[Dictionary] = []`, je `{"from": String, "prop": String, "to": String}`
- `func link(from_id: String, prop: String, to_id: String) -> void`: gibt es schon einen Eintrag mit gleichem `from` und `prop`, nur dessen `to` ersetzen; sonst anhängen
- `func unlink(from_id: String, prop: String) -> bool`: Eintrag entfernen, `true` wenn es ihn gab
- `func targets_of(from_id: String) -> Array[String]`: alle `to` dieses Objekts, sortiert, ohne Doppelte
- `func referrers_of(to_id: String) -> Array[String]`: alle `from`, die auf `to_id` zeigen, sortiert, ohne Doppelte
- `func remove_object(id: String) -> int`: alle Einträge mit `from == id` oder `to == id` entfernen, Anzahl zurückgeben
- `func rename(old_id: String, new_id: String) -> void`: in allen Einträgen `from` und `to` ersetzen
- `func dangling(existing: Array[String]) -> Array[Dictionary]`: alle Einträge, deren `to` nicht in `existing` steht, in Einfügereihenfolge
- `func to_dict() -> Dictionary` (`{"refs": [...]}`) und `static func from_dict(d: Dictionary) -> ReferenceIndex` (Werte mit `str(...)`)

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Werte aus Dictionaries immer mit Typ lesen (`var to: String = r["to"]`), Ergebnisse in `var result: Array[String] = []` sammeln. Einrückung nur mit Tabs.

## Tests
`tests/test_reference_index.gd` (in `setup()`: `link("kamera", "ziel", "spieler")`, `link("tuer", "schalter", "hebel")`, `link("hud", "ziel", "spieler")`):
- `test_ersetzen`: `link("kamera", "ziel", "gegner")` → `targets_of("kamera")` ist `["gegner"]`, `refs.size()` bleibt 3
- `test_rueckwaerts`: `referrers_of("spieler")` ist `["hud", "kamera"]`
- `test_loeschen`: `remove_object("spieler")` ist 2, `refs.size()` 1
- `test_umbenennen`: `rename("spieler", "held")` → `referrers_of("held")` hat 2 Einträge, `referrers_of("spieler")` ist leer
- `test_verwaist`: `dangling(["kamera", "tuer", "hud", "spieler"])` hat genau einen Eintrag, dessen `to` „hebel“ ist
- `test_speichern`: über `JSON.parse_string(JSON.stringify(idx.to_dict()))` und `from_dict` wieder 3 Einträge
