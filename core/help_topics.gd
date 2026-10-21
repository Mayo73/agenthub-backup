extends RefCounted
class_name HelpTopics

var topics: Dictionary = {}


func add(id: String, title: String, text: String, contexts: Array[String]) -> void:
	var topic: Dictionary = {
		"id": id,
		"title": title,
		"text": text,
		"contexts": contexts
	}
	topics[id] = topic


func for_context(context: String) -> Array[String]:
	var result: Array[String] = []

	for id in topics:
		var t: Dictionary = topics[id]
		var ctx: Array = t["contexts"]
		if context in ctx:
			result.append(id)

	result.sort_custom(func(a: String, b: String):
		var title_a: String = topics[a]["title"]
		var title_b: String = topics[b]["title"]
		return title_a < title_b
	)

	return result


func search(query: String) -> Array[String]:
	if query.is_empty():
		return []

	var result: Array[String] = []
	var lower_query: String = query.to_lower()

	for id in topics:
		var t: Dictionary = topics[id]
		var title: String = t["title"].to_lower()
		var text: String = t["text"].to_lower()

		if lower_query in title or lower_query in text:
			result.append(id)

	result.sort_custom(func(a: String, b: String):
		return a < b
	)

	return result


func text_of(id: String) -> String:
	if not id in topics:
		return ""

	var t: Dictionary = topics[id]
	return t["text"]


func lines(context: String) -> Array[String]:
	var ids: Array[String] = for_context(context)
	var result: Array[String] = []

	for id in ids:
		var t: Dictionary = topics[id]
		var title: String = t["title"]
		var text: String = t["text"]
		result.append("%s: %s" % [title, text])

	return result
