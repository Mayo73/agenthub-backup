class_name ChatLog
extends RefCounted
## Speichert Nachrichten zwischen zwei Testpersonen pro Match.

const MAX_LENGTH := 500

var messages: Array[Dictionary] = []
var next_n := 1


func send(match_id: String, from_id: String, text: String) -> bool:
	text = text.strip_edges()
	if text.is_empty():
		return false
	if text.length() > MAX_LENGTH:
		text = text.substr(0, MAX_LENGTH)
	messages.append({"match_id": match_id, "from": from_id, "text": text, "n": next_n})
	next_n += 1
	return true


func messages_for(match_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for msg in messages:
		if msg["match_id"] == match_id:
			result.append(msg)
	return result


func last_message(match_id: String) -> Dictionary:
	var msgs := messages_for(match_id)
	if msgs.is_empty():
		return {}
	return msgs[-1]


func count_for(match_id: String) -> int:
	return messages_for(match_id).size()


func to_dict() -> Dictionary:
	return {"messages": messages, "next_n": next_n}


static func from_dict(d: Dictionary) -> ChatLog:
	var chat := ChatLog.new()
	if d.has("messages"):
		chat.messages = d["messages"]
		for msg in chat.messages:
			msg["n"] = int(msg.get("n", 1))
	else:
		chat.messages = []
	if d.has("next_n"):
		chat.next_n = int(d["next_n"])
	else:
		chat.next_n = 1
	return chat
