class_name MateCall
extends RefCounted
## Partnersuche wie bei Spore: Jeder neue Größenabschnitt bringt einen Ruf.
## Der Ruf lässt einen Partner vor der Zelle erscheinen; wer ihn erreicht, kommt in den Zelleditor.

const PARTNER_DIST := 250.0
const PARTNER_RADIUS := 12.0

var charges := 0
## Lage des Partners oder null, solange keiner gerufen wurde.
var partner_pos: Variant = null


func add_charge() -> void:
	charges += 1


func can_call() -> bool:
	return charges > 0 and partner_pos == null


## Ruft einen Partner in Blickrichtung vor die Zelle. false, wenn kein Ruf bereitsteht.
func call_partner(player_pos: Vector2, heading: float) -> bool:
	if not can_call():
		return false
	charges -= 1
	partner_pos = player_pos + Vector2.from_angle(heading) * PARTNER_DIST
	return true


func reached(player_pos: Vector2, player_radius: float) -> bool:
	if partner_pos == null:
		return false
	return player_pos.distance_to(partner_pos as Vector2) <= player_radius + PARTNER_RADIUS


## Nach dem Editorbesuch verschwindet der Partner.
func finish() -> void:
	partner_pos = null
