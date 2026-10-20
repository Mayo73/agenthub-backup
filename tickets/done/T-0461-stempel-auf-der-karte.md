---
id: T-0461
title: Stempel „SPARRING“ und „NEIN“ auf der Profilkarte
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9): Beim Wischen erscheint auf der Karte ein schräger Stempel, rechts „SPARRING“ (grün), links „NEIN“ (rot), umso deutlicher, je weiter gewischt wird. Hier entstehen die Logik in `SwipeGesture` und die beiden Stempel in `ProfileCard`; der Einbau in den Entdecken-Bildschirm folgt in T-0462.

## Dateien
- `scripts/swipe_gesture.gd` – zwei neue Funktionen
- `scripts/ui_style.gd` – Baustein `stamp()`
- `scripts/profile_card.gd` – Stempel anlegen und zeigen
- `tests/test_swipe_gesture.gd`, `tests/test_profile_card.gd` – Tests ergänzen

## Akzeptanzkriterien
- `SwipeGesture`:
  - `func stamp_strength() -> float`: 0.0, wenn nicht `active`; sonst `clampf(absf(offset.x) / THRESHOLD, 0.0, 1.0)`.
  - `func stamp_kind() -> int`: `Result.NONE`, wenn nicht `active` oder `offset.x == 0`; `Result.LIKE` bei `offset.x > 0`, `Result.PASS` bei `offset.x < 0`.
- `UiStyle.stamp(text: String, color: Color) -> PanelContainer`: durchsichtige Fläche (`panel(Color(0, 0, 0, 0), 12)`) mit Rahmen 5 px in `color`, Beschriftung `label(text, SIZE_TITLE, color)` als einziges Kind (`get_child(0)`), `autowrap_mode` aus, `mouse_filter` ignorieren.
- `ProfileCard`:
  - `var like_stamp: PanelContainer` = `UiStyle.stamp("SPARRING", UiStyle.LIKE)`, `rotation = -0.3`, oben links auf der Karte (`position = Vector2(40, 120)`).
  - `var pass_stamp: PanelContainer` = `UiStyle.stamp("NEIN", UiStyle.PASS)`, `rotation = 0.3`, oben rechts (`position = Vector2(360, 100)`).
  - Beide liegen in einem eigenen `Control` (`stamp_layer`, `mouse_filter` ignorieren) als **letztes** Kind der Karte, damit sie über Porträt und Text liegen. Anfangs unsichtbar.
  - `func show_stamp(kind: int, strength: float) -> void`: bei `SwipeGesture.Result.LIKE` ist nur `like_stamp` sichtbar mit `modulate.a = strength`, bei `PASS` nur `pass_stamp`, bei `NONE` oder `strength <= 0` beide unsichtbar.

## Tests
- `tests/test_swipe_gesture.gd`:
  - `test_stempel_staerke`: `begin(Vector2(100, 600))`, `move(Vector2(180, 600))` → `stamp_strength()` 0.5, `stamp_kind()` `Result.LIKE`; `move(Vector2(-200, 600))` → 1.0 und `Result.PASS`; nach `finish()` → 0.0 und `Result.NONE`.
  - `test_stempel_ohne_wischen`: ohne `begin` → `stamp_strength()` 0.0, `stamp_kind()` `Result.NONE`.
- `tests/test_profile_card.gd`:
  - `test_stempel_anfangs_unsichtbar`: `like_stamp.visible` und `pass_stamp.visible` falsch; `(like_stamp.get_child(0) as Label).text` ist „SPARRING“, beim anderen „NEIN“.
  - `test_stempel_zeigen`: `show_stamp(SwipeGesture.Result.LIKE, 0.6)` → `like_stamp.visible` wahr, `like_stamp.modulate.a` 0.6, `pass_stamp.visible` falsch; `show_stamp(SwipeGesture.Result.PASS, 1.0)` → umgekehrt; `show_stamp(SwipeGesture.Result.NONE, 0.0)` → beide unsichtbar.

Review (20.10.2026): selbst umgesetzt. Der Agent hatte die bestehenden Testdateien test_swipe_gesture.gd und test_profile_card.gd überschrieben statt ergänzt (214 → 204 Tests).
