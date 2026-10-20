---
id: T-0437
title: Fischszene blendet aus dem Wasserblau ein
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Der Editor blendet am Ende ins Wasserblau; die Fischszene beginnt mit derselben Farbe und blendet weich ein.

## Dateien
- `scripts/fish_main.gd` – Einblendung
- `tests/test_fish_main.gd` – Test ergänzen

## Akzeptanzkriterien
- `fish_main.gd`: `const FADE_IN := 0.8`; `var fade_rect: ColorRect` (Name „FadeIn“) auf einer eigenen `CanvasLayer` (`layer = 20`), ganzer Bildschirm, Farbe `FishWorld.WATER_COLOR` mit Alpha 1, `mouse_filter` ignorieren; `var fade_left := FADE_IN`
- In `_process`: solange `fade_left > 0`: `fade_left -= delta`, Alpha = `clampf(fade_left / FADE_IN, 0.0, 1.0)`; bei 0 `fade_rect.visible = false`

## Tests
`tests/test_fish_main.gd`:
- `test_einblenden`: Fischszene laden (wie die anderen Tests der Datei) → `fade_rect.color.a` 1.0; `fish._process(0.4)` → Alpha ungefähr 0.5; `fish._process(0.5)` → `fade_rect.visible` falsch

Review (20.10.2026): gemergt, nachgebessert: Einblendfläche war nur 1×1 Pixel statt bildschirmfüllend, Funktion in setup_fade_in umbenannt, verdorbenes Anführungszeichen im Kommentar zurückgesetzt.
