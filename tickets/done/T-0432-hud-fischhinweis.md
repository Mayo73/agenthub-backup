---
id: T-0432
title: HUD zeigt im letzten Abschnitt den Weg zum Fisch
project: zellenphase
priority: 4
after: T-0431, T-0430
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Im letzten Größenabschnitt zeigt das HUD dauerhaft z. B. „Teile 5/8 – ab 6 kannst du im Editor zum Fisch werden“.

## Dateien
- `scripts/hud.gd` – Zeile für den Hinweis
- `scripts/main.gd` – Hinweis aktualisieren
- `tests/test_hud.gd` – Test ergänzen

## Akzeptanzkriterien
- `hud.gd`: `var fish_label: Label` (Name „FishHint“) unter den Balken im `box`; `func show_fish_hint(text: String) -> void` setzt den Text und macht das Label nur bei nicht leerem Text sichtbar
- `main.gd`: in `_process` `hud.show_fish_hint(FishReadiness.hud_text(progress, unlocks))`

## Tests
- `tests/test_hud.gd` (gibt es die Datei nicht, neu anlegen; HUD an `root` hängen, in `teardown()` freigeben): `test_fischhinweis` (`show_fish_hint("abc")` → sichtbar mit Text „abc“; `show_fish_hint("")` → unsichtbar)

Review (20.10.2026): gemergt.
