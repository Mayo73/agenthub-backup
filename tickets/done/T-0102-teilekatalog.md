---
id: T-0102
title: Teilekatalog (PartCatalog)
project: zellenphase
priority: 3
---
## Ziel
Ein Katalog aller Zellteile wie in der Spore-Zellenphase: drei Mundwerkzeuge, drei Antriebe, drei Waffen und zwei Augen, mit DNA-Kosten, Wirkung auf Tempo und Wendigkeit und der Reihenfolge, in der Teilefunde sie freischalten.

## Dateien
- `scripts/part_catalog.gd`: neu
- `tests/test_part_catalog.gd`: neu

## Akzeptanzkriterien
`scripts/part_catalog.gd` genau so:
```gdscript
class_name PartCatalog
extends RefCounted
## Teile für Zelle und Zelleditor (Vorbild: Spore-Zellenphase).
## category: "maul", "antrieb", "waffe" oder "auge". cost in DNA.
## speed: Zuschlag auf das Höchsttempo in Pixeln pro Sekunde, turn: Zuschlag auf die Wendegeschwindigkeit in Radiant pro Sekunde.

const PARTS := {
	"filtermaul": {"name": "Filtermaul", "category": "maul", "cost": 10, "speed": 0.0, "turn": 0.0},
	"kiefer": {"name": "Kiefer", "category": "maul", "cost": 10, "speed": 0.0, "turn": 0.0},
	"ruessel": {"name": "Rüssel", "category": "maul", "cost": 20, "speed": 0.0, "turn": 0.0},
	"geissel": {"name": "Geißel", "category": "antrieb", "cost": 15, "speed": 60.0, "turn": 0.0},
	"wimpern": {"name": "Wimpern", "category": "antrieb", "cost": 15, "speed": 20.0, "turn": 3.0},
	"duese": {"name": "Düse", "category": "antrieb", "cost": 25, "speed": 100.0, "turn": -1.0},
	"stachel": {"name": "Stachel", "category": "waffe", "cost": 15, "speed": 0.0, "turn": 0.0},
	"gift": {"name": "Giftdrüse", "category": "waffe", "cost": 20, "speed": 0.0, "turn": 0.0},
	"elektro": {"name": "Elektroorgan", "category": "waffe", "cost": 25, "speed": 0.0, "turn": 0.0},
	"knopfauge": {"name": "Knopfauge", "category": "auge", "cost": 5, "speed": 0.0, "turn": 0.0},
	"stielauge": {"name": "Stielauge", "category": "auge", "cost": 5, "speed": 0.0, "turn": 0.0},
}
## Von Anfang an verfügbar.
const STARTER := ["filtermaul", "kiefer", "knopfauge"]
## Reihenfolge, in der Teilefunde neue Teile freischalten.
const UNLOCK_ORDER := ["geissel", "stachel", "wimpern", "ruessel", "gift", "stielauge", "duese", "elektro"]


## Alle IDs in der Reihenfolge der Tabelle.
static func ids() -> Array[String]:
	var result: Array[String] = []
	for id: String in PARTS:
		result.append(id)
	return result


static func exists(id: String) -> bool:
	return PARTS.has(id)


static func data(id: String) -> Dictionary:
	return PARTS.get(id, {})


static func name_of(id: String) -> String:
	return data(id).get("name", "")


static func cost_of(id: String) -> int:
	return data(id).get("cost", 0)


static func category_of(id: String) -> String:
	return data(id).get("category", "")


## Alle IDs einer Kategorie in Tabellenreihenfolge.
static func ids_in_category(category: String) -> Array[String]:
	var result: Array[String] = []
	for id in ids():
		if category_of(id) == category:
			result.append(id)
	return result
```

## Tests
`tests/test_part_catalog.gd` mit `extends "res://tests/base_test.gd"`:
- `test_elf_teile`: `PartCatalog.ids().size()` ist 11
- `test_freischaltung_vollstaendig`: `PartCatalog.STARTER.size() + PartCatalog.UNLOCK_ORDER.size()` ist 11; jede ID aus `PartCatalog.ids()` kommt in `STARTER` und `UNLOCK_ORDER` zusammen genau einmal vor
- `test_kategorien`: mit typisiertem Array `var maeuler: Array[String] = ["filtermaul", "kiefer", "ruessel"]` ist `PartCatalog.ids_in_category("maul")` gleich `maeuler`; `PartCatalog.ids_in_category("waffe").size()` ist 3; `PartCatalog.category_of("wimpern")` ist `"antrieb"`; `PartCatalog.category_of("gibtsnicht")` ist `""`
- `test_maeuler_passen_zu_diet`: `PartCatalog.category_of(Diet.FILTERMAUL)`, `(Diet.KIEFER)` und `(Diet.RUESSEL)` sind jeweils `"maul"`
- `test_kosten_und_namen`: `PartCatalog.cost_of("elektro")` ist 25; `cost_of("gibtsnicht")` ist 0; `name_of("ruessel")` ist `"Rüssel"`; `name_of("gibtsnicht")` ist `""`; `PartCatalog.exists("geissel")` wahr

Review (16.10.2026): gemergt.
