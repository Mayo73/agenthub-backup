---
id: T-0315
title: Fischszene spielt die eigene Musik
project: zellenphase
priority: 3
after: T-0314, T-0313
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Die Fischszene spielt `FishMusic.theme()` statt der Musik der Zellenphase.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Test anhängen

## Akzeptanzkriterien
- In `_ready()` gibt es den Block, der `audio = GameAudio.new()` anlegt und mit `add_child(audio)` einhängt. Direkt **vor** `add_child(audio)` die Zeile `audio.music.stream = FishMusic.theme()` einfügen (vor dem Einhängen, weil `GameAudio._ready()` die Musik startet).
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_fischmusik`: `fish.audio.music.stream is AudioStreamWAV` wahr; `(fish.audio.music.stream as AudioStreamWAV).data.size()` ist gleich `FishMusic.theme().data.size()` und ungleich `CellMusic.theme().data.size()`

Review (18.10.2026): gemergt.
