---
id: T-0070
title: Musik im Hauptmenü
project: drift
priority: 3
after: T-0055, T-0064
---
## Ziel
Auch im Hauptmenü läuft die Hintergrundmusik, etwas leiser als im Rennen.

## Dateien
- `scripts/main_menu.gd`
- `tests/test_main_menu.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable `var music: AudioStreamPlayer`
- In `_ready()` direkt nach `add_child(click_player)`:
```gdscript
	music = AudioStreamPlayer.new()
	music.name = "Music"
	music.stream = MusicSynth.theme()
	music.volume_db = -18.0
	add_child(music)
	music.play()
```
- Sonst nichts ändern.

## Tests
In `tests/test_main_menu.gd` neue Methode `test_menuemusik`:
- `menu.get_node("Music") is AudioStreamPlayer` ist wahr
- `menu.music.stream is AudioStreamWAV` ist wahr
- `absf(menu.music.volume_db - (-18.0)) < 0.001`

Review (16.10.2026): gemergt.
