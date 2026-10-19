extends RefCounted
## SimClock – Simulationstakt von 120 Schritten pro Sekunde, unabhängig von der Bildrate.
## GUI, CLI und Agenten steuern ihn gleich. Reine Logik ohne Nodes.
class_name SimClock

signal stepped(step: int)

const HZ := 120
const MAX_STEPS_PER_ADVANCE := 12

var running := false
var step_count := 0
var accumulator := 0.0


func start() -> void:
	running = true


func pause() -> void:
	running = false
	accumulator = 0.0


func step(n: int = 1) -> int:
	var ausgefuehrt := 0
	if n <= 0:
		return ausgefuehrt
	for i in range(n):
		step_count += 1
		stepped.emit(step_count)
		ausgefuehrt += 1
	return ausgefuehrt


func advance(delta: float) -> int:
	if not running:
		return 0

	accumulator += delta

	var schritte := 0
	var schritte_pro_schritt := 1.0 / HZ

	while accumulator >= schritte_pro_schritt and schritte < MAX_STEPS_PER_ADVANCE:
		step_count += 1
		stepped.emit(step_count)
		accumulator -= schritte_pro_schritt
		schritte += 1

	if schritte == MAX_STEPS_PER_ADVANCE:
		accumulator = 0.0

	return schritte


func time() -> float:
	return step_count / float(HZ)


func reset() -> void:
	step_count = 0
	accumulator = 0.0
	running = false


func state() -> Dictionary:
	return {"running": running, "step": step_count, "time": time()}
