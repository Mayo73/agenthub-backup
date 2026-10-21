class_name StateMachine
extends RefCounted

## Ein einfacher Zustandsautomat, der über Übergänge definiert wird.
## Kann im Editor oder Agenten ohne Script konfiguriert werden.
var current: String = ""
var transitions: Dictionary = {}
var history: Array[String] = []


func _init(start: String = "") -> void:
	current = start
	if not start.is_empty():
		history.append(start)


## Übergang hinzufügen: von 'from' bei Ereignis 'event' nach 'to'.
## from == "*" gilt in jedem Zustand.
func add(from: String, event: String, to: String) -> void:
	var key := "%s|%s" % [from, event]
	transitions[key] = str(to)


## Gibt den Zielzustand für ein Ereignis zurück.
## Erst wird <current>|<event> gesucht, dann "*"|<event>, sonst "".
func target_for(event: String) -> String:
	var key := "%s|%s" % [current, event]
	if transitions.has(key):
		return str(transitions.get(key))
	key = "*|%s" % event
	if transitions.has(key):
		return str(transitions.get(key))
	return ""


## Prüft, ob ein Ereignis im aktuellen Zustand möglich ist.
func can(event: String) -> bool:
	var ziel := target_for(event)
	return not ziel.is_empty()


## Sendet ein Ereignis. Übergang wird ausgeführt, falls vorhanden.
## Gibt true zurück, wenn ein Übergang durchgeführt wurde, sonst false.
func send(event: String) -> bool:
	var ziel := target_for(event)
	if ziel.is_empty():
		return false
	current = ziel
	history.append(current)
	return true


## Gibt alle Ereignisse zurück, die im aktuellen Zustand möglich sind.
## Enthält sowohl eigene als auch '*'-Ereignisse, ohne Doppelte, sortiert.
func events() -> Array[String]:
	var result: Array[String] = []
	var event_set: Dictionary = {}
	for key in transitions:
		if "|" in key:
			var parts: Array = []
			parts = key.split("|", false, 1)
			var from: String = str(parts[0])
			var event: String = str(parts[1])
			if from == current or from == "*":
				event_set[event] = true
	for e in event_set.keys():
		result.append(str(e))
	result.sort()
	return result


## Serialisiert den aktuellen Zustand.
func to_dict() -> Dictionary:
	return {
		"current": current,
		"transitions": transitions,
		"history": history
	}


## Erstellt einen StateMachine aus einer serialisierten Darstellung.
static func from_dict(d: Dictionary) -> StateMachine:
	var sm := StateMachine.new()
	sm.current = str(d.get("current", ""))
	sm.history.clear()
	for entry in d.get("history", []):
		sm.history.append(str(entry))
	sm.transitions = d.get("transitions", {})
	return sm
