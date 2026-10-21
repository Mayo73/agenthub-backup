---
id: T-0498
title: TestProtocol – Testprotokoll mit Versionen, Seed, Eingaben und Messwerten
project: hub-engine
priority: 4
---
## Ziel
Muss 10 „Beobachten und testen“: „Testprotokoll enthält Engine-/Projektversion, Ausgangszustand, Seed, Schrittweite, Eingabefolge, Messwerte, erwartete Toleranzen und Ergebnisse.“ Diese Klasse sammelt das und gibt es als JSON und Markdown aus.

## Dateien
- `core/test_protocol.gd` – neu, Klasse `TestProtocol`
- `tests/test_test_protocol.gd` – neu

## Akzeptanzkriterien
`class_name TestProtocol`, `extends RefCounted`.
- Felder: `var name := ""`, `var engine_version := ""`, `var project_version := ""`, `var seed_value := 0`, `var step := 1.0 / 120.0`, `var start_state: Dictionary = {}`, `var inputs: Array[Dictionary] = []` (je `{"step": int, "action": String, "pressed": bool}`), `var measurements: Array[Dictionary] = []`
- `func add_input(step_no: int, action: String, pressed: bool) -> void`
- `func measure(key: String, value: float, expected: float, tolerance: float) -> bool`: hängt `{"key", "value", "expected", "tolerance", "ok": absf(value - expected) <= tolerance}` an und gibt `ok` zurück
- `func passed() -> bool`: alle Messungen ok (ohne Messungen `false`)
- `func failures() -> Array[String]`: je fehlgeschlagener Messung `"%s: %.3f statt %.3f ± %.3f"`
- `func to_dict() -> Dictionary` und `static func from_dict(d: Dictionary) -> TestProtocol` (Zahlen aus JSON mit `int(...)`/`float(...)`)
- `func markdown() -> String`: Überschrift `"# Testprotokoll " + name`, Zeilen für Engine, Projekt, Seed, Schrittweite (`"%.4f s"`), Anzahl Eingaben, dann eine Tabelle `| Messwert | Ist | Soll | Toleranz | Ergebnis |` mit „ok“/„FEHLER“, am Ende `"Ergebnis: bestanden"` bzw. `"Ergebnis: nicht bestanden"`

## Tests
`tests/test_test_protocol.gd`:
- `test_messung`: `measure("weite", 10.02, 10.0, 0.05)` wahr, `measure("hoehe", 3.0, 2.0, 0.5)` falsch → `passed()` falsch, `failures().size()` 1, enthält „hoehe“
- `test_leer`: neues Protokoll → `passed()` falsch
- `test_markdown`: mit `name = "wurf"`, einer Eingabe und einer bestandenen Messung → Text enthält „# Testprotokoll wurf“, „| weite |“ und „Ergebnis: bestanden“
- `test_speichern`: `TestProtocol.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))` hat gleiche `seed_value`, `inputs.size()`, `measurements.size()` und `passed()`

Review (21.10.2026): selbst umgesetzt. Der Agent scheiterte 5x an Typfehlern (PackedStringArray.new, Variant-Inferenz, untypisierte Arrays). core/test_protocol.gd und tests/test_test_protocol.gd mit 4 Tests, verify grün.
