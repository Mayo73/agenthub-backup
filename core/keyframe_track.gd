class_name KeyframeTrack
extends RefCounted

var keys: Array[Dictionary] = []
var loop := false

func add_key(t: float, value: float) -> void:
	var epsilon := 0.0001
	# Prüfen, ob es schon einen Schlüssel mit fast gleichem t gibt
	for i in range(keys.size()):
		var kt: float = keys[i]["t"]
		if abs(kt - t) < epsilon:
			keys[i]["value"] = value
			return
	# Keine gleiche Zeit gefunden – an der richtigen Stelle einfügen
	var insert_index := keys.size()
	for i in range(keys.size()):
		if keys[i]["t"] > t:
			insert_index = i
			break
	var new_key: Dictionary = {"t": t, "value": value}
	keys.insert(insert_index, new_key)

func length() -> float:
	if keys.is_empty():
		return 0.0
	return keys[-1]["t"]

func sample(t: float) -> float:
	if keys.is_empty():
		return 0.0
	if keys.size() == 1:
		return keys[0]["value"]

	# Bei Loop t in Bereich [0, length()) falten
	if loop and length() > 0:
		t = fposmod(t, length())

	# Prüfen ob t außerhalb des Bereichs liegt
	var first_t: float = keys[0]["t"]
	var last_t: float = keys[-1]["t"]

	if t <= first_t:
		return keys[0]["value"]
	if t >= last_t:
		return keys[-1]["value"]

	# Linear zwischen den beiden Nachbarn interpolieren
	for i in range(keys.size() - 1):
		var kt_curr: float = keys[i]["t"]
		var val_curr: float = keys[i]["value"]
		var kt_next: float = keys[i + 1]["t"]
		var val_next: float = keys[i + 1]["value"]

		if t > kt_curr and t < kt_next:
			return lerpf(val_curr, val_next, (t - kt_curr) / (kt_next - kt_curr))

	# Sollte theoretisch nicht erreicht werden
	return keys[-1]["value"]
