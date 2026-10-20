---
id: T-0426
title: EvolutionTimeline – Entwicklungsschritte merken
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Entwicklungszeitstrahl wie in Spore“: Eine Logikklasse merkt sich jeden Entwicklungsschritt der eigenen Lebensform (Start, Größenabschnitte, Editorbesuche, Übergang zum Fisch, Fischgrößen, Verbesserungen), damit eine Leiste sie später als kleine Bilder zeigen kann.

## Dateien
- `scripts/evolution_timeline.gd` – neu, Klasse `EvolutionTimeline`
- `tests/test_evolution_timeline.gd` – neu

## Akzeptanzkriterien
`class_name EvolutionTimeline`, `extends RefCounted`:
- Arten als Konstanten: `const START := "start"`, `const STAGE := "abschnitt"`, `const EDITOR := "editor"`, `const FISH := "fisch"`, `const FISH_SIZE := "fischgroesse"`, `const UPGRADE := "verbesserung"`
- `const DIET_COLORS := {...}`: Pflanzenfresser `Color("#6CCB5F")`, Fleischfresser `Color("#D9534F")`, Allesfresser `Color("#9B6CD9")`. Als Schlüssel die Konstanten aus `scripts/diet.gd` verwenden (vorher lesen).
- `var entries: Array[Dictionary] = []`, je Eintrag `{"kind": String, "label": String, "diet": String, "time": float, "color": Color, "phase": String}`; `phase` ist `"zelle"` oder `"fisch"`
- `func add(kind: String, label: String, diet: String, time: float, color: Color, phase: String = "zelle") -> void`: hängt einen Eintrag an
- `func size() -> int`, `func last() -> Dictionary` (`{}` ohne Einträge)
- `static func diet_color(diet: String) -> Color`: Farbe aus `DIET_COLORS`, unbekannt → `Color.GRAY`
- `static func time_text(seconds: float) -> String`: `"%d:%02d" % [minuten, sekunden]` (z. B. 75.0 → „1:15“)
- `func to_dict() -> Dictionary`: `{"entries": [...]}`, Farben als `color.to_html()`; `static func from_dict(d: Dictionary) -> EvolutionTimeline` liest das wieder ein (`Color.html(...)`, `float(...)` für `time`)

## Tests
`tests/test_evolution_timeline.gd`:
- `test_hinzufuegen`: zwei Einträge → `size()` 2, `last()["kind"]` ist der zweite
- `test_leer`: `last()` ist `{}`
- `test_ernaehrungsfarbe`: `diet_color` für alle drei Ernährungen wie in `DIET_COLORS`, unbekannt → `Color.GRAY`
- `test_zeit`: `time_text(75.0)` → „1:15“, `time_text(5.0)` → „0:05“
- `test_speichern`: Eintrag mit Farbe `Color(0.5, 0.9, 0.8)` über `to_dict()`, `JSON.stringify`, `JSON.parse_string`, `from_dict` → gleiche Art, Beschriftung, Zeit; Farbe ungefähr gleich (`is_equal_approx` auf r, g, b)

Review (20.10.2026): gemergt.
