---
id: T-0122
title: Fähigkeitsvorschau im Zelleditor (EditorPreview)
project: zellenphase
priority: 3
---
## Ziel
Der Zelleditor zeigt vor dem Bestätigen, wie sich Tempo, Wendigkeit, Ernährung und Waffen durch den Umbau ändern (Lastenheft: „Fähigkeitsänderungen vor dem Bestätigen anzeigen“). Diese Klasse liefert die Textzeilen dafür.

## Dateien
- `scripts/editor_preview.gd`: neu
- `tests/test_editor_preview.gd`: neu

## Akzeptanzkriterien
`scripts/editor_preview.gd` genau so:
```gdscript
class_name EditorPreview
extends RefCounted
## Fähigkeitsvorschau im Zelleditor: Werte vorher und nachher als Textzeilen.

const DIET_NAMES := {
	"pflanzenfresser": "Pflanzenfresser",
	"fleischfresser": "Fleischfresser",
	"allesfresser": "Allesfresser",
	"": "keine Nahrung",
}


static func diet_name(diet: String) -> String:
	return str(DIET_NAMES.get(diet, diet))


## Namen der eingebauten Waffen (Kategorie "waffe"), jede Art nur einmal, in Einbaureihenfolge.
static func weapons(build: CellBuild) -> Array[String]:
	var result: Array[String] = []
	for p in build.parts:
		var id: String = p["id"]
		if PartCatalog.category_of(id) == "waffe" and not result.has(PartCatalog.name_of(id)):
			result.append(PartCatalog.name_of(id))
	return result


## "Tempo: 220 → 280"; bei gleichem Wert ohne Pfeil: "Tempo: 220".
static func line(label: String, before: String, after: String) -> String:
	if before == after:
		return "%s: %s" % [label, before]
	return "%s: %s → %s" % [label, before, after]


static func lines(original: CellBuild, working: CellBuild, stage: int) -> Array[String]:
	var result: Array[String] = []
	result.append(line("Tempo", str(roundi(CellStats.max_speed(original, stage))), str(roundi(CellStats.max_speed(working, stage)))))
	result.append(line("Wendigkeit", "%.1f" % CellStats.turn_rate(original), "%.1f" % CellStats.turn_rate(working)))
	result.append(line("Ernährung", diet_name(CellStats.diet(original)), diet_name(CellStats.diet(working))))
	var names := ", ".join(PackedStringArray(weapons(working)))
	result.append("Waffen: %s" % (names if names != "" else "keine"))
	return result
```

## Tests
`tests/test_editor_preview.gd` mit `extends "res://tests/base_test.gd"`, `var a: CellBuild`, `setup()`: `a = CellBuild.starter(Diet.PFLANZENFRESSER)`.
- `test_unveraendert`: `var l := EditorPreview.lines(a, a.copy(), 0)` → `l.size()` ist 4; `l[0]` ist `"Tempo: 220"`; `l[1]` ist `"Wendigkeit: 6.0"`; `l[2]` ist `"Ernährung: Pflanzenfresser"`; `l[3]` ist `"Waffen: keine"`
- `test_umbau`: `var b := a.copy()`, `b.add_part("geissel", Vector2(-1, 0))`, `b.add_part("stachel", Vector2(0, 1))`, `b.add_part("kiefer", Vector2(0.9, 0.3))` → `EditorPreview.lines(a, b, 0)[0]` ist `"Tempo: 220 → 280"`; `[2]` ist `"Ernährung: Pflanzenfresser → Allesfresser"`; `[3]` ist `"Waffen: Stachel"`
- `test_waffen_einmal`: `var b := CellBuild.new()`, zweimal `"stachel"` und einmal `"gift"` einbauen (Lagen beliebig) → `EditorPreview.weapons(b)` hat Größe 2, `[0]` ist `"Stachel"`, `[1]` ist `"Giftdrüse"`
- `test_namen`: `EditorPreview.diet_name("")` ist `"keine Nahrung"`; `diet_name(Diet.FLEISCHFRESSER)` ist `"Fleischfresser"`
- `test_wendigkeit`: `var b := a.copy()`, `b.add_part("wimpern", Vector2(0, 1))` → `EditorPreview.lines(a, b, 0)[1]` ist `"Wendigkeit: 6.0 → 9.0"`

Review (16.10.2026): gemergt.
