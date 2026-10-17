---
id: T-0143
title: Audiobusse Musik und Effekte (AudioBuses)
project: zellenphase
priority: 3
---
## Ziel
Musik und Effekte werden getrennt in der Lautstärke geregelt (Lastenheft „Audio und Einstellungen“). Dafür braucht es die Audiobusse „Musik“ und „Effekte“; `main.gd` stellt ihre Lautstärke in `apply_settings()` ein, sobald es sie gibt.

## Dateien
- `scripts/audio_buses.gd`: neu
- `tests/test_audio_buses.gd`: neu

## Akzeptanzkriterien
`scripts/audio_buses.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_audio_buses.gd` mit `extends "res://tests/base_test.gd"`:
- `test_anlegen`: `AudioBuses.ensure()` → `AudioServer.get_bus_index("Musik") >= 0` wahr; `AudioServer.get_bus_index("Effekte") >= 0` wahr
- `test_doppelt`: `AudioBuses.ensure()`, `var n := AudioServer.bus_count`, nochmal `AudioBuses.ensure()` → `AudioServer.bus_count` ist `n`
- `test_ziel`: `AudioBuses.ensure()`, `var idx := AudioServer.get_bus_index("Effekte")` → `str(AudioServer.get_bus_send(idx))` ist `"Master"`

Review (16.10.2026): gemergt.
