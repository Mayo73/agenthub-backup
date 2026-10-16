extends "res://tests/base_test.gd"


func test_noten() -> void:
	check_eq(CellMusic.LEAD.size(), 32, "LEAD hat 32 Noten")
	check_eq(CellMusic.BASS.size(), 32, "BASS hat 32 Noten")
	check(CellMusic.REST == MusicSynth.REST, "REST ist gleich MusicSynst.REST")


func test_schleife() -> void:
	var t := CellMusic.theme()
	check(t.loop_mode == AudioStreamWAV.LOOP_FORWARD, "loop_mode ist LOOP_FORWARD")
	check_eq(t.loop_end, 32 * int(0.5 * SoundSynth.MIX_RATE), "loop_end stimmt mit 32 Noten überein")
	check_eq(t.data.size(), t.loop_end * 2, "data.size() ist doppelt so groß wie loop_end (16-Bit)")
