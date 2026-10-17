---
id: T-0116
title: Aussehen des Zellkörpers (CellLook)
project: zellenphase
priority: 5
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Im Zelleditor lassen sich Farbe, Muster und Körperform (Streckung) ändern. Diese Klasse hält die Werte, prüft sie und liefert den Umriss des Körpers.

## Dateien
- `scripts/cell_look.gd`: neu
- `tests/test_cell_look.gd`: neu

## Akzeptanzkriterien
`scripts/cell_look.gd` mit `class_name CellLook`, `extends RefCounted` und:
- Konstanten: `const PATTERNS := ["keins", "punkte", "streifen", "flecken"]`, `const MIN_STRETCH := 0.7`, `const MAX_STRETCH := 1.5`, `const DEFAULT_COLOR := Color(0.5, 0.88, 0.82)`
- Variablen: `var color := DEFAULT_COLOR`, `var pattern := "keins"`, `var stretch := 1.0` (Kommentar: Streckung in Blickrichtung, 1 = rund, über 1 länglich, unter 1 breit)
- `func set_pattern(p: String) -> bool`: nur Werte aus `PATTERNS`; sonst `false` und keine Änderung
- `func set_stretch(s: float) -> void`: setzt `stretch` auf `clampf(s, MIN_STRETCH, MAX_STRETCH)`
- `func copy() -> CellLook`: unabhängige Kopie mit gleichen Werten
- `func outline(radius: float, points: int = 24) -> PackedVector2Array`: Ellipse mit `points` Punkten; Punkt `i` ist `Vector2(cos(a) * radius * stretch, sin(a) * radius / stretch)` mit `a = TAU * i / points`
- `func to_dict() -> Dictionary`: `{"color": color.to_html(), "pattern": pattern, "stretch": stretch}`
- `static func from_dict(d: Dictionary) -> CellLook`: neuer `CellLook`; `color = Color.from_string(str(d.get("color", "")), DEFAULT_COLOR)`; `pattern` über `set_pattern(str(d.get("pattern", "keins")))`; `stretch` über `set_stretch(float(d.get("stretch", 1.0)))`

## Tests
`tests/test_cell_look.gd` mit `extends "res://tests/base_test.gd"`, `var look: CellLook`, `setup()`: `look = CellLook.new()`.
- `test_standard`: `look.pattern` ist `"keins"`, `look.stretch` ist 1.0, `look.color.is_equal_approx(CellLook.DEFAULT_COLOR)` wahr
- `test_muster`: `look.set_pattern("punkte")` wahr; `look.set_pattern("karo")` falsch; `look.pattern` ist `"punkte"`
- `test_streckung_begrenzt`: `look.set_stretch(3.0)` → `look.stretch` ist 1.5; `look.set_stretch(0.1)` → 0.7; `look.set_stretch(1.2)` → 1.2
- `test_umriss`: `look.set_stretch(1.5)`, `var o := look.outline(10.0, 4)` → `o.size()` ist 4; `o[0].is_equal_approx(Vector2(15, 0))` wahr; `o[1].is_equal_approx(Vector2(0, 10.0 / 1.5))` wahr
- `test_speichern_laden`: `look.color = Color(1, 0, 0)`, `look.set_pattern("streifen")`, `look.set_stretch(1.2)`; `var l2 := CellLook.from_dict(look.to_dict())` → `l2.color.is_equal_approx(Color(1, 0, 0))` wahr, `l2.pattern` ist `"streifen"`, `l2.stretch` ist 1.2
- `test_laden_leer`: `var l2 := CellLook.from_dict({})` → `l2.pattern` ist `"keins"`, `l2.stretch` ist 1.0, `l2.color.is_equal_approx(CellLook.DEFAULT_COLOR)` wahr
- `test_kopie_unabhaengig`: `var c := look.copy()`, `c.set_pattern("flecken")`, `c.set_stretch(1.4)` → `look.pattern` ist `"keins"`, `look.stretch` ist 1.0

Review (16.10.2026): gemergt.
