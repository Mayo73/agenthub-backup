---
id: T-0456
title: Zeitstrahl-Knopf auch im Pausemenü der Fischphase
project: zellenphase
priority: 4
after: T-0439
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Die Fischphase nutzt dasselbe Pausemenü wie die Zellenphase. Dessen Knopf „Zeitstrahl“ ist dort noch nicht verbunden.

## Dateien
- `scripts/fish_main.gd` – Signal verbinden
- `tests/test_fish_main.gd` – Test ergänzen

## Akzeptanzkriterien
Vorher `scripts/fish_main.gd` (`toggle_pause`, `toggle_timeline` aus T-0439) und in `scripts/main.gd` die Funktionen `_on_pause_open_timeline` und `_unhandled_input` lesen.
- `fish_main.gd`: `pause_menu.open_timeline` ruft `func _on_pause_open_timeline() -> void`: ist das Spiel pausiert, zuerst `toggle_pause()` (hebt die Pause auf und schließt das Menü), dann `toggle_timeline()`
- Esc (Aktion `pause`) schließt einen offenen Zeitstrahl, statt das Pausemenü zu öffnen (wie in `main.gd`)

## Tests
`tests/test_fish_main.gd` ergänzen:
- `test_zeitstrahl_aus_pause`: `toggle_pause()`, dann `pause_menu.timeline_button.pressed.emit()` → Zeitstrahl sichtbar, `pause_menu.visible` falsch, `paused` falsch

Review (20.10.2026): fehlgeschlagen (Laufzeitfehler in den Tests der Fischszene), von Claude selbst umgesetzt.
