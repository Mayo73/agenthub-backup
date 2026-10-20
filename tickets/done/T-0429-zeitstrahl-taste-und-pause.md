---
id: T-0429
title: Zeitstrahl mit Taste T und im Pausemenü öffnen
project: zellenphase
priority: 4
after: T-0427, T-0428
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Im Spiel öffnet Taste T den Zeitstrahl, im Pausemenü gibt es dafür einen Knopf. Unter der Leiste steht der Rückblick (Statistik der Partie).

## Dateien
- `scripts/controls.gd` – Aktion `zeitstrahl` (Taste T)
- `scripts/pause_menu.gd` – Knopf „Zeitstrahl“
- `scripts/main.gd` – Ansicht anlegen und umschalten
- `tests/test_main_wiring.gd`, `tests/test_pause_menu.gd` – Tests ergänzen

## Akzeptanzkriterien
- `controls.gd`: Aktion `"zeitstrahl"` in `ACTIONS` ergänzen und in `setup()` mit `KEY_T` belegen (wie die anderen Tasten)
- `pause_menu.gd`: `signal open_timeline`, `var timeline_button: Button` mit Text „Zeitstrahl“, direkt unter dem Knopf zum Weiterspielen; Klick sendet `open_timeline`
- `main.gd`: `var timeline_view: TimelineView` auf einer eigenen `CanvasLayer` (Name „TimelineLayer“, `layer = 6`), zunächst unsichtbar.
  - `func toggle_timeline() -> void`: beim Öffnen `timeline_view.show_timeline(timeline)` und `timeline_view.show_stats(stats.summary_lines())`, dann sichtbar; sonst ausblenden
  - Aktion `zeitstrahl` in `_unhandled_input` ruft `toggle_timeline()`; `pause_menu.open_timeline` ebenfalls (Pausemenü vorher schließen)
  - Esc (Aktion `pause`) schließt eine offene Zeitstrahl-Ansicht, statt das Pausemenü zu öffnen

## Tests
- `tests/test_main_wiring.gd`: `test_zeitstrahl_umschalten` (Partie starten, zweimal `toggle_timeline()` → erst sichtbar, dann unsichtbar; nach dem ersten Mal `timeline_view.item_count()` gleich `timeline.size()`)
- `tests/test_pause_menu.gd` (gibt es die Datei nicht, neu anlegen): `test_zeitstrahl_knopf` (`timeline_button.pressed.emit()` sendet `open_timeline`)
- in `tests/test_main_wiring.gd`: `test_zeitstrahl_aktion` (`InputMap.has_action("zeitstrahl")` nach `Controls.setup()`)

Review (20.10.2026): gemergt, nachgebessert: entfernte Tests in test_pause_menu.gd wiederhergestellt, Knopf direkt unter „Weiter“, Öffnen aus der Pause hebt die Pause richtig auf, T nicht im Menü oder Editor.
