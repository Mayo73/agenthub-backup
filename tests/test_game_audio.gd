extends "res://tests/base_test.gd"

var audio: GameAudio


func setup() -> void:
	audio = GameAudio.new()


func teardown() -> void:
	audio.free()


func test_aufbau() -> void:
	check_eq(audio.streams.size(), 9, "streams.size() ist 9")
	check_eq(audio.voices.size(), 6, "voices.size() ist 6")
	check(str(audio.music.bus) == "Musik", "str(audio.music.bus) ist Musik")
	check(str(audio.voices[0].bus) == "Effekte", "str(audio.voices[0].bus) ist Effekte")
	var music_stream := audio.music.stream as AudioStreamWAV
	check(music_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "loop_mode ist LOOP_FORWARD")


func test_abspielen() -> void:
	check(audio.play("treffer") == true, "audio.play(\"treffer\") wahr")
	check_eq(audio.last_played, "treffer", "last_played ist treffer")
	check_eq(audio.play_count, 1, "play_count ist 1")
	check(audio.voices[0].stream == audio.streams["treffer"], "voices[0].stream == streams[treffer]")
	check_eq(audio.next_voice, 1, "next_voice ist 1")


func test_unbekannt() -> void:
	check(audio.play("gibtsnicht") == false, "audio.play(\"gibtsnicht\") falsch")
	check_eq(audio.play_count, 0, "play_count ist 0")
	check_eq(audio.last_played, "", "last_played ist leer")


func test_reihum() -> void:
	for _i in 7:
		audio.play("klick")
	check_eq(audio.next_voice, 1, "next_voice ist 1 nach 7-mal spielen")
	check_eq(audio.play_count, 7, "play_count ist 7")
