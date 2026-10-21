class_name TestProtocol
extends RefCounted
## Testprotokoll mit Versionen, Ausgangszustand, Seed, Schrittweite, Eingaben und Messwerten.

var name := ""
var engine_version := ""
var project_version := ""
var seed_value := 0
var step := 1.0 / 120.0
var start_state: Dictionary = {}
## Je Eingabe {"step": int, "action": String, "pressed": bool}.
var inputs: Array[Dictionary] = []
## Je Messung {"key", "value", "expected", "tolerance", "ok"}.
var measurements: Array[Dictionary] = []


func add_input(step_no: int, action: String, pressed: bool) -> void:
	inputs.append({"step": step_no, "action": action, "pressed": pressed})


## Hängt eine Messung an und gibt zurück, ob sie innerhalb der Toleranz liegt.
func measure(key: String, value: float, expected: float, tolerance: float) -> bool:
	var ok: bool = absf(value - expected) <= tolerance
	measurements.append({"key": key, "value": value, "expected": expected, "tolerance": tolerance, "ok": ok})
	return ok


## Bestanden, wenn es Messungen gibt und alle ok sind.
func passed() -> bool:
	if measurements.is_empty():
		return false
	for m in measurements:
		var ok: bool = m.get("ok", false)
		if not ok:
			return false
	return true


func failures() -> Array[String]:
	var result: Array[String] = []
	for m in measurements:
		var ok: bool = m.get("ok", false)
		if not ok:
			result.append("%s: %.3f statt %.3f ± %.3f" % [m.get("key", ""), m.get("value", 0.0), m.get("expected", 0.0), m.get("tolerance", 0.0)])
	return result


func to_dict() -> Dictionary:
	return {
		"name": name,
		"engine_version": engine_version,
		"project_version": project_version,
		"seed": seed_value,
		"step": step,
		"start_state": start_state.duplicate(true),
		"inputs": inputs.duplicate(true),
		"measurements": measurements.duplicate(true),
	}


static func from_dict(d: Dictionary) -> TestProtocol:
	var p := TestProtocol.new()
	p.name = str(d.get("name", ""))
	p.engine_version = str(d.get("engine_version", ""))
	p.project_version = str(d.get("project_version", ""))
	p.seed_value = int(d.get("seed", 0))
	p.step = float(d.get("step", 1.0 / 120.0))
	var state: Dictionary = d.get("start_state", {})
	p.start_state = state.duplicate(true)
	var raw_inputs: Array = d.get("inputs", [])
	for item in raw_inputs:
		var i: Dictionary = item
		p.add_input(int(i.get("step", 0)), str(i.get("action", "")), bool(i.get("pressed", false)))
	var raw_measurements: Array = d.get("measurements", [])
	for item in raw_measurements:
		var m: Dictionary = item
		p.measurements.append({
			"key": str(m.get("key", "")),
			"value": float(m.get("value", 0.0)),
			"expected": float(m.get("expected", 0.0)),
			"tolerance": float(m.get("tolerance", 0.0)),
			"ok": bool(m.get("ok", false)),
		})
	return p


func markdown() -> String:
	var lines: Array[String] = []
	lines.append("# Testprotokoll " + name)
	lines.append("")
	lines.append("- Engine: " + engine_version)
	lines.append("- Projekt: " + project_version)
	lines.append("- Seed: %d" % seed_value)
	lines.append("- Schrittweite: %.4f s" % step)
	lines.append("- Eingaben: %d" % inputs.size())
	lines.append("")
	lines.append("| Messwert | Ist | Soll | Toleranz | Ergebnis |")
	lines.append("|---|---|---|---|---|")
	for m in measurements:
		var ok: bool = m.get("ok", false)
		lines.append("| %s | %.3f | %.3f | %.3f | %s |" % [m.get("key", ""), m.get("value", 0.0), m.get("expected", 0.0), m.get("tolerance", 0.0), "ok" if ok else "FEHLER"])
	lines.append("")
	lines.append("Ergebnis: bestanden" if passed() else "Ergebnis: nicht bestanden")
	return "\n".join(lines) + "\n"
