class_name AnimationClip
extends RefCounted

var name := ""
var loop := false
var tracks: Dictionary = {}


func track(property: String) -> KeyframeTrack:
	if not tracks.has(property):
		tracks[property] = KeyframeTrack.new()
	return tracks[property]


func key(property: String, t: float, value: float) -> void:
	track(property).add_key(t, value)


func length() -> float:
	var max_len: float = 0.0
	for p in tracks:
		var tr: KeyframeTrack = tracks[p]
		var len: float = tr.length()
		if len > max_len:
			max_len = len
	return max_len


func sample_all(t: float) -> Dictionary:
	var result: Dictionary = {}

	if length() > 0 and loop:
		t = fposmod(t, length())

	for p in tracks:
		var tr: KeyframeTrack = tracks[p]
		result[p] = tr.sample(t)

	return result


func to_dict() -> Dictionary:
	var dict_tracks: Dictionary = {}
	for p in tracks:
		var tr: KeyframeTrack = tracks[p]
		var pairs: Array = []
		for i in range(tr.keys.size()):
			var key_data: Dictionary = tr.keys[i]
			pairs.append([key_data["t"], key_data["value"]])
		dict_tracks[p] = pairs

	return {
		"name": name,
		"loop": loop,
		"tracks": dict_tracks
	}


static func from_dict(d: Dictionary) -> AnimationClip:
	var clip: AnimationClip = AnimationClip.new()
	clip.name = str(d.get("name", ""))
	clip.loop = d.get("loop", false)

	var raw_tracks: Dictionary = d.get("tracks", {})
	for p in raw_tracks:
		var raw: Array = raw_tracks[p]
		var tr: KeyframeTrack = clip.track(p)
		for i in range(raw.size()):
			var pair: Array = raw[i]
			var t: float = float(pair[0])
			var value: float = float(pair[1])
			tr.add_key(t, value)

	return clip
