extends "res://tests/base_test.gd"


func test_namen() -> void:
	var keys := FishSounds.all().keys()
	keys.sort()
	check_eq(keys, ["biss", "verbessern"], "Schlüssel sortiert")


func test_biss() -> void:
	var s := FishSounds.bite()
	check(s.loop_mode == AudioStreamWAV.LOOP_DISABLED, "loop_mode ist LOOP_DISABLED")
	check(s.data.size() > 0, "data.size() > 0")
	check(s.mix_rate == SoundSynth.MIX_RATE, "mix_rate ist SoundSynth.MIX_RATE")


func test_verbessern_laenger_als_biss() -> void:
	var upgrade_size := FishSounds.upgrade().data.size()
	var bite_size := FishSounds.bite().data.size()
	check(upgrade_size > bite_size, "upgrade().data.size() > bite().data.size()")


func test_keine_namensgleichheit() -> void:
	var fish_keys := FishSounds.all().keys()
	var cell_keys := CellSounds.all().keys()
	for fk in fish_keys:
		check(not cell_keys.has(fk), "Kein Schlüssel aus FishSounds.all() ist auch ein Schlüssel von CellSounds.all()")
