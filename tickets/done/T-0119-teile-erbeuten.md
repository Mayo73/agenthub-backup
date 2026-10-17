---
id: T-0119
title: Teile von besiegten Zellen (PartDrops)
project: zellenphase
priority: 3
after: T-0105
---
## Ziel
Wie bei Spore lassen sich Teile auch von besiegten Zellen erbeuten: Jede Zellart trägt ein typisches Teil. Ist es noch gesperrt, bekommt der Spieler es beim Sieg.

## Dateien
- `scripts/part_drops.gd`: neu
- `tests/test_part_drops.gd`: neu

## Akzeptanzkriterien
`scripts/part_drops.gd` genau so:
```gdscript
class_name PartDrops
extends RefCounted
## Teile, die besiegte Zellen hinterlassen: jede Art trägt ein typisches Teil.

const DROPS := {
	"blasenling": "stielauge",
	"schnapper": "geissel",
	"stachelkugel": "stachel",
	"giftling": "gift",
	"zitterzelle": "elektro",
	"weidezelle": "wimpern",
	"hornjaeger": "duese",
	"riesenschlund": "ruessel",
}


## Das Teil, das eine besiegte Zelle dieser Art bringt; "" wenn es schon frei ist oder die Art unbekannt ist.
static func drop_for(species_id: String, unlocks: PartUnlocks) -> String:
	var part: String = DROPS.get(species_id, "")
	if part == "" or unlocks.is_unlocked(part):
		return ""
	return part
```

## Tests
`tests/test_part_drops.gd` mit `extends "res://tests/base_test.gd"`:
- `test_jede_art_hat_ein_teil`: für jede ID aus `SpeciesCatalog.ids()` ist `PartDrops.DROPS.has(id)` wahr und `PartCatalog.exists(PartDrops.DROPS[id])` wahr
- `test_gesperrtes_teil`: `PartDrops.drop_for("zitterzelle", PartUnlocks.new())` ist `"elektro"`
- `test_schon_frei`: `var u := PartUnlocks.new()`, `u.unlock("stachel")` → `PartDrops.drop_for("stachelkugel", u)` ist `""`
- `test_unbekannt`: `PartDrops.drop_for("gibtsnicht", PartUnlocks.new())` ist `""`

Review (16.10.2026): gemergt.
