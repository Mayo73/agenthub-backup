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
