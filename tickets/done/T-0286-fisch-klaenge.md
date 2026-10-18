---
id: T-0286
title: Musik, Wasserrauschen und Klänge in der Fischszene
project: zellenphase
priority: 4
after: T-0283, T-0285
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Klänge“: Die Fischszene ist bisher stumm. Sie bekommt dieselbe `GameAudio` wie die Zellenphase (Musik, Wasserrauschen) plus die Klänge aus `FishSounds`, und spielt sie bei Fressen, Wachsen, Bissen, Treffern, Tod und Verbesserung.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Variable `var audio: GameAudio` unter `var evolve: EvolveMenu`.
- In `_ready()` direkt nach `Controls.setup()`:
```gdscript
	audio = GameAudio.new()
	audio.name = "Audio"
	audio.streams.merge(FishSounds.all())
	add_child(audio)
```
- Klänge abspielen (jeweils genau eine Zeile `audio.play("<name>")` einfügen):
  - `feed_player()`: in der Schleife über die gefressene Nahrung als erste Zeile im Schleifenrumpf → `"fressen_pflanze"`
  - `eat_value(value)`: im Zweig, in dem der Fisch gewachsen ist, direkt nach `hud.show_message("Dein Fisch ist gewachsen!")` → `"wachsen"`
  - `player_bites()`: direkt nachdem ein Biss trifft (im Rumpf von `if FishCombat.bite_hits(...)`, als erste Zeile) → `"biss"`
  - `predators_bite()`: direkt nach der Zeile, in der `player_health` Schaden bekommt → `"treffer"`
  - `check_death()`: direkt nach `deaths += 1` → `"tod"`
  - `_on_upgraded(slot)`: als erste Zeile → `"verbessern"`
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen; vor jedem Test alle KI-Fische entfernen (`for f in fish.fishes.duplicate(): fish.remove_fish(f)`):
- `test_audio_knoten`: `fish.get_node("Audio") is GameAudio` wahr; `fish.audio.streams.has("biss")` und `fish.audio.streams.has("fressen_pflanze")` wahr
- `test_klang_verbessern`: `fish.progress.dna = 20`; `fish.toggle_evolve()`; `fish.evolve.try_upgrade("schwanz")` → `fish.audio.last_played` ist `"verbessern"`
- `test_klang_wachsen`: `fish.eat_value(FishProgress.GROWTH_NEEDED[0])` → `fish.audio.last_played` ist `"wachsen"`
- `test_klang_tod`: `fish.player_health.hp = 0.0`; `fish.check_death()` → `fish.audio.last_played` ist `"tod"`

Review (18.10.2026): gemergt.
