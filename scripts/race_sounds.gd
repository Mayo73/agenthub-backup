extends Node
## Spielt die Countdown-Töne. update() einmal pro Physik-Schritt mit dem RaceState aufrufen.

var beep_player: AudioStreamPlayer
var go_player: AudioStreamPlayer
var last_text := ""
var beeps := 0
var gos := 0


func _init() -> void:
	beep_player = AudioStreamPlayer.new()
	beep_player.name = "Beep"
	beep_player.stream = SoundBank.beep()
	add_child(beep_player)
	go_player = AudioStreamPlayer.new()
	go_player.name = "Go"
	go_player.stream = SoundBank.go_beep()
	add_child(go_player)


## Spielt einen Ton, sobald sich der Countdown-Text ändert.
func update(race: RaceState) -> void:
	var text := race.countdown_text()
	if text == last_text:
		return
	last_text = text
	if text == "Los!":
		gos += 1
		if go_player.is_inside_tree():
			go_player.play()
	elif text != "":
		beeps += 1
		if beep_player.is_inside_tree():
			beep_player.play()


## Für einen Neustart: Der nächste Countdown piept wieder von vorn.
func reset() -> void:
	last_text = ""
