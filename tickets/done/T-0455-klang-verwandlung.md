---
id: T-0455
title: Klang „verwandlung“ beim Übergang zum Fisch
project: zellenphase
priority: 4
after: T-0436, T-0450
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Die Verwandlung der Zelle in den Fisch bekommt einen eigenen Klang: ein langsam steigendes, schimmerndes Anschwellen über etwa 2,5 Sekunden.

## Dateien
- `scripts/cell_sounds.gd` – neuer Klang
- `scripts/main.gd` – Klang beim Start der Verwandlung abspielen
- `tests/test_cell_sounds.gd` – Test ergänzen

## Akzeptanzkriterien
Vorher `scripts/sound_synth.gd` und `scripts/cell_sounds.gd` lesen.
- `static func transform() -> AudioStreamWAV`: Mischung (`SoundSynth.mix`) aus `SoundSynth.sweep(220.0, 660.0, 2.5, SoundSynth.Wave.SINE, 0.3)` und `SoundSynth.sweep(330.0, 990.0, 2.5, SoundSynth.Wave.SINE, 0.12)`, mit `SoundSynth.fade_out(...)`, nicht in Schleife (`make_stream(..., false)`)
- In `all()` unter dem Namen `"verwandlung"` eintragen
- `main.gd`: dort, wo nach dem Klick auf „Zum Fisch entwickeln“ die Verwandlung startet (vorher lesen, T-0436), `audio.play("verwandlung")`

## Tests
`tests/test_cell_sounds.gd`:
- `test_verwandlung`: `CellSounds.all()` enthält `"verwandlung"`; `get_length()` des Klangs liegt zwischen 2.3 und 2.7 Sekunden

Review (20.10.2026): von Claude selbst umgesetzt (Klang verwandlung nach Ticket, Zähler in zwei bestehenden Tests von 9 auf 10).
