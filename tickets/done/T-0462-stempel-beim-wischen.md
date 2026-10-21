---
id: T-0462
title: Stempel beim Wischen im Entdecken-Bildschirm zeigen
project: sparring
priority: 2
after: T-0461
---
## Ziel
Auftrag „Modernes Design“ (M9): Während der Finger die Karte zieht, zeigt sie den passenden Stempel aus T-0461. Nach dem Loslassen oder einer Entscheidung verschwindet er.

## Dateien
- `scripts/discover_screen.gd` – Stempel beim Ziehen und Zurücksetzen
- `tests/test_discover_screen.gd` – Tests ergänzen

## Akzeptanzkriterien
- In `_on_card_gui_input` beim `InputEventScreenDrag` nach `gesture.move(...)` zusätzlich `card.show_stamp(gesture.stamp_kind(), gesture.stamp_strength())`.
- `_reset_card_position()` ruft zusätzlich `card.show_stamp(SwipeGesture.Result.NONE, 0.0)` auf.
- Sonst ändert sich nichts am Verhalten (bestehende Tests bleiben unverändert grün).

## Tests
`tests/test_discover_screen.gd`:
- `test_stempel_beim_ziehen`: `InputEventScreenTouch` mit `pressed = true`, `position = Vector2(100, 600)` an `screen._on_card_gui_input(...)`; dann `InputEventScreenDrag` mit `position = Vector2(180, 600)` → `screen.card.like_stamp.visible` wahr, `screen.card.like_stamp.modulate.a` 0.5; dann Drag auf `Vector2(-100, 600)` → `pass_stamp.visible` wahr, `like_stamp.visible` falsch.
- `test_stempel_nach_loslassen`: Touch bei `Vector2(100, 600)`, Drag auf `Vector2(150, 600)` (zu kurz für eine Entscheidung), dann `InputEventScreenTouch` mit `pressed = false` → beide Stempel unsichtbar, `screen.current().id` weiter „p02“.

Review (20.10.2026): gemergt.
