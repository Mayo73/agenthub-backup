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
	"flimmerling": "geissel",
	"panzerling": "stachel",
	"schwebqualle": "wimpern",
}


## Das Teil, das eine besiegte Zelle dieser Art bringt; "" wenn es schon frei ist oder die Art unbekannt ist.
static func drop_for(species_id: String, unlocks: PartUnlocks) -> String:
	var part: String = DROPS.get(species_id, "")
	if part == "" or unlocks.is_unlocked(part):
		return ""
	return part
