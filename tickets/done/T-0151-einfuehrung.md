---
id: T-0151
title: Kurze Einführung als Hinweise (TutorialHints)
project: zellenphase
priority: 3
---
## Ziel
Kurze, kontextbezogene Hinweise zu Bewegung, Fressen, Partnerruf, Editor und Gefahr (Lastenheft Soll „Einführung“). Jeder Hinweis erscheint pro Partie höchstens einmal; welche schon kamen, wird gespeichert.

## Dateien
- `scripts/tutorial_hints.gd`: neu
- `tests/test_tutorial_hints.gd`: neu

## Akzeptanzkriterien
`scripts/tutorial_hints.gd` genau so:
```gdscript
class_name TutorialHints
extends RefCounted
## Kurze Einführung: Jeder Hinweis erscheint pro Partie höchstens einmal.

const TEXTS := {
	"bewegen": "Halte die linke Maustaste gedrückt, um zu schwimmen – oder nutze WASD.",
	"fressen": "Gut gemacht! Nahrung bringt DNA und Wachstum. Dein Maul bestimmt, was du fressen kannst.",
	"partner": "Du bist gewachsen! Drücke C oder die rechte Maustaste, um einen Partner zu rufen.",
	"editor": "Im Zelleditor baust du deine Zelle um. Neue Teile kosten DNA.",
	"gefahr": "Vorsicht! Andere Zellen können dich beißen. Flieh oder wehr dich.",
}

var shown: Array[String] = []


## Text des Hinweises, wenn er noch nicht gezeigt wurde (und merkt ihn sich); sonst "". Unbekannte IDs ergeben "".
func trigger(id: String) -> String:
	if not TEXTS.has(id) or shown.has(id):
		return ""
	shown.append(id)
	return TEXTS[id]


func to_array() -> Array:
	return shown.duplicate()


## Stellt die gezeigten Hinweise wieder her; unbekannte und doppelte Einträge werden übergangen.
static func from_array(data: Array) -> TutorialHints:
	var h := TutorialHints.new()
	for entry in data:
		var id := str(entry)
		if TEXTS.has(id) and not h.shown.has(id):
			h.shown.append(id)
	return h
```

## Tests
`tests/test_tutorial_hints.gd` mit `extends "res://tests/base_test.gd"`, `var h: TutorialHints`; `setup()`: `h = TutorialHints.new()`.
- `test_einmal`: `h.trigger("bewegen")` ist `TutorialHints.TEXTS["bewegen"]`; ein zweites `h.trigger("bewegen")` ist `""`
- `test_unbekannt`: `h.trigger("gibtsnicht")` ist `""`; `h.shown.size()` ist 0
- `test_speichern`: `h.trigger("fressen")`, `h.trigger("editor")`; `var k := TutorialHints.from_array(h.to_array())` → `k.shown.size()` ist 2; `k.trigger("fressen")` ist `""`; `k.trigger("gefahr") != ""` wahr
- `test_kaputte_daten`: `TutorialHints.from_array(["bewegen", "bewegen", "quatsch", 5]).shown.size()` ist 1
- `test_alle_texte`: `TutorialHints.TEXTS.size()` ist 5

Review (16.10.2026): gemergt.
