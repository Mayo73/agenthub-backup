class_name AudioBuses
extends RefCounted
## Legt die Audiobusse "Musik" und "Effekte" an (beide gehen in "Master"). main.gd regelt ihre Lautstärke.

const MUSIC := "Musik"
const SFX := "Effekte"


## Legt fehlende Busse an; mehrfacher Aufruf schadet nicht.
static func ensure() -> void:
	for bus_name in [MUSIC, SFX]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")
