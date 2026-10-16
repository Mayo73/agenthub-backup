extends "res://tests/base_test.gd"

func test_anlegen() -> void:
	AudioBuses.ensure()
	check(AudioServer.get_bus_index("Musik") >= 0, "Bus 'Musik' wurde nicht angelegt")
	check(AudioServer.get_bus_index("Effekte") >= 0, "Bus 'Effekte' wurde nicht angelegt")


func test_doppelt() -> void:
	AudioBuses.ensure()
	var n := AudioServer.bus_count
	AudioBuses.ensure()
	check(AudioServer.bus_count == n, "Bus-Anzahl bei doppeltem Aufruf gestiegen: %d statt %d" % [AudioServer.bus_count, n])


func test_ziel() -> void:
	AudioBuses.ensure()
	var idx := AudioServer.get_bus_index("Effekte")
	check(str(AudioServer.get_bus_send(idx)) == "Master", "Bus 'Effekte' sendet nicht nach 'Master': %s" % AudioServer.get_bus_send(idx))
