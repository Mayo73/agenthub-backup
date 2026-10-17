class_name FishInput
extends RefCounted
## Übersetzt Tasten in Schwimmbefehle für FishMotion.step().


## Ergebnis Vector3(thrust, turn, climb): thrust 1 vorwärts, -0.5 rückwärts; turn 1 links, -1 rechts; climb 1 auf, -1 ab.
static func combine(forward: bool, back: bool, left: bool, right: bool, up: bool, down: bool) -> Vector3:
	var thrust := 0.0
	if forward:
		thrust += 1.0
	if back:
		thrust -= 0.5
	var turn := 0.0
	if left:
		turn += 1.0
	if right:
		turn -= 1.0
	var climb := 0.0
	if up:
		climb += 1.0
	if down:
		climb -= 1.0
	return Vector3(thrust, turn, climb)


## Liest die Aktionen: "hoch" oder "schwimmen" vorwärts, "runter" rückwärts, "links"/"rechts" drehen,
## "auftauchen"/"abtauchen" neigen.
static func read() -> Vector3:
	return combine(
		Input.is_action_pressed("hoch") or Input.is_action_pressed("schwimmen"),
		Input.is_action_pressed("runter"),
		Input.is_action_pressed("links"),
		Input.is_action_pressed("rechts"),
		Input.is_action_pressed("auftauchen"),
		Input.is_action_pressed("abtauchen"))
