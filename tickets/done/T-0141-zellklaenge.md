---
id: T-0141
title: Klänge der Zellenphase (CellSounds)
project: zellenphase
priority: 3
after: T-0140
---
## Ziel
Alle Spielklänge der Zellenphase als fertige Streams, erzeugt mit `SoundSynth` (keine Audiodateien; Higgsfield liefert keine Effekte). Lastenheft „Audio“: Wasseratmosphäre, Fressen, Treffer, Wachstum, Editoraktionen.

## Dateien
- `scripts/cell_sounds.gd`: neu
- `tests/test_cell_sounds.gd`: neu

## Akzeptanzkriterien
`scripts/cell_sounds.gd` genau so:
```gdscript
class_name CellSounds
extends RefCounted
## Klänge der Zellenphase, alle mit SoundSynth erzeugt (keine Audiodateien).


## Pflanzen fressen: kurzer, steigender Ton.
static func eat_plant() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(500.0, 900.0, 0.12, SoundSynth.Wave.SINE, 0.4)), false)


## Fleisch fressen: dumpfes Rauschen mit tiefem Ton.
static func eat_meat() -> AudioStreamWAV:
	var crunch := SoundSynth.lowpass(SoundSynth.noise(0.15, 0.6, 5), 0.2)
	var low := SoundSynth.tone(180.0, 0.15, SoundSynth.Wave.SINE, 0.3)
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.mix(crunch, low)), false)


## Treffer: fallender, rauer Ton.
static func hit() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(300.0, 120.0, 0.2, SoundSynth.Wave.SQUARE, 0.3)), false)


## Wachstum: zwei steigende Töne.
static func grow() -> AudioStreamWAV:
	var a := SoundSynth.sweep(300.0, 900.0, 0.6, SoundSynth.Wave.SINE, 0.35)
	var b := SoundSynth.sweep(450.0, 1350.0, 0.6, SoundSynth.Wave.SINE, 0.15)
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.mix(a, b)), false)


## Tod: langer, fallender Ton.
static func death() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(400.0, 80.0, 0.8, SoundSynth.Wave.SAW, 0.3)), false)


## Klick für Menüknöpfe.
static func click() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(880.0, 0.05, SoundSynth.Wave.SINE, 0.3), false)


## Teil im Editor eingebaut.
static func place_part() -> AudioStreamWAV:
	var a := SoundSynth.tone(520.0, 0.08, SoundSynth.Wave.SINE, 0.3)
	var b := SoundSynth.tone(780.0, 0.08, SoundSynth.Wave.SINE, 0.2)
	return SoundSynth.make_stream(SoundSynth.mix(a, b), false)


## Teil im Editor entfernt.
static func remove_part() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(600.0, 300.0, 0.1, SoundSynth.Wave.SINE, 0.3)), false)


## Wasserrauschen, 2 Sekunden, Schleife.
static func water_loop() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.lowpass(SoundSynth.noise(2.0, 0.5, 11), 0.05), true)


## Alle Einzelklänge nach Namen (ohne das Wasserrauschen).
static func all() -> Dictionary:
	return {
		"fressen_pflanze": eat_plant(),
		"fressen_fleisch": eat_meat(),
		"treffer": hit(),
		"wachsen": grow(),
		"tod": death(),
		"klick": click(),
		"teil_setzen": place_part(),
		"teil_entfernen": remove_part(),
	}
```

## Tests
`tests/test_cell_sounds.gd` mit `extends "res://tests/base_test.gd"`:
- `test_alle`: `var a := CellSounds.all()` → `a.size()` ist 8; `a.has("wachsen")` wahr; für jeden Wert `v` in `a.values()`: `v is AudioStreamWAV` wahr und `(v as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_DISABLED` wahr
- `test_laengen`: `CellSounds.eat_plant().data.size()` ist `int(0.12 * SoundSynth.MIX_RATE) * 2`; `CellSounds.grow().data.size()` ist `int(0.6 * SoundSynth.MIX_RATE) * 2`
- `test_wasser`: `var w := CellSounds.water_loop()` → `w.loop_mode == AudioStreamWAV.LOOP_FORWARD` wahr; `w.loop_end` ist `int(2.0 * SoundSynth.MIX_RATE)`
- `test_nicht_stumm`: in `CellSounds.hit().data` ist mindestens ein Byte ungleich 0 (Schleife mit Zähler, Zähler > 0)

Review (16.10.2026): gemergt.
