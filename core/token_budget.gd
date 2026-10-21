class_name TokenBudget
extends RefCounted

## Schätzt die Token-Anzahl für einen Text.
## Nimmt an: ca. 4 Zeichen pro Token.
static func estimate(text: String) -> int:
	return ceili(float(text.length()) / 4.0)


## Kürzt eine Liste von Einträgen auf ein Token-Budget.
## Eintrag 0 (Systemanweisung) bleibt immer erhalten.
## Danach werden von hinten Einträge hinzugefügt, solange das Budget passt.
static func trim(entries: Array, budget: int) -> Array:
	if entries.is_empty():
		return []

	var selected_indices: Dictionary = {0: true}
	var current_tokens: int = estimate(entries[0])

	for i in range(entries.size() - 1, 0, -1):
		var tokens: int = estimate(entries[i])
		if current_tokens + tokens <= budget:
			current_tokens += tokens
			selected_indices[i] = true
		else:
			break

	var result: Array = []
	for i in range(entries.size()):
		if i in selected_indices:
			result.append(entries[i])
	return result
