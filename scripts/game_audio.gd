class_name GameAudio
extends Node
## Spielt Musik, Wasserrauschen und Klänge. Klänge werden über ihren Namen aus CellSounds.all() abgespielt.

const VOICES := 6

var streams: Dictionary = {}
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var next_voice := 0
var last_played := ""
var play_count := 0


func _init() -> void:
	AudioBuses.ensure()
	streams = CellSounds.all()
	music = AudioStreamPlayer.new()
	music.name = "Music"
	music.bus = AudioBuses.MUSIC
	music.stream = CellMusic.theme()
	add_child(music)
	ambience = AudioStreamPlayer.new()
	ambience.name = "Ambience"
	ambience.bus = AudioBuses.SFX
	ambience.stream = CellSounds.water_loop()
	ambience.volume_db = -12.0
	add_child(ambience)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.name = "Voice%d" % i
		p.bus = AudioBuses.SFX
		add_child(p)
		voices.append(p)


func _ready() -> void:
	music.play()
	ambience.play()


## Spielt den Klang sound_name auf der nächsten Stimme (reihum). false bei unbekanntem Namen.
func play(sound_name: String) -> bool:
	if not streams.has(sound_name):
		return false
	var p := voices[next_voice]
	next_voice = (next_voice + 1) % VOICES
	p.stream = streams[sound_name]
	if p.is_inside_tree():
		p.play()
	last_played = sound_name
	play_count += 1
	return true
