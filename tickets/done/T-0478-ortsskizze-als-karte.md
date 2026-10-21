---
id: T-0478
title: Ortsskizze im Treffen als Karte
project: sparring
priority: 2
after: T-0470
---
## Ziel
Auftrag „Modernes Design“ (M9): Die Ortsskizze im Treffvorschlag liegt in einer abgerundeten Karte mit weichem Schatten und Überschrift, passend zur Statuskarte.

## Dateien
- `scripts/meeting_screen.gd`
- `tests/test_meeting_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variable `var place_card: PanelContainer` mit Stilbox `"panel"` = `UiStyle.card_panel(UiStyle.RAISED, UiStyle.RADIUS)` und `content_margin_left/right/top/bottom` 12; `size_flags_horizontal = Control.SIZE_EXPAND_FILL`.
- Darin ein `VBoxContainer` (`separation` 8) mit `UiStyle.label("Ortsskizze", UiStyle.SIZE_SMALL, UiStyle.MUTED)` und danach `place_view`.
- `place_card` steht in `vbox` an der Stelle, an der vorher `place_view` stand; `place_view` ist nicht mehr direktes Kind von `vbox`.
- `place_view.custom_minimum_size = Vector2(0, 260)`.

## Tests
- `test_ortsskizze_als_karte`: nach dem Aufbau (wie in den bestehenden Tests) ist `place_view.get_parent().get_parent()` gleich `place_card`, und `(place_card.get_theme_stylebox("panel") as StyleBoxFlat).shadow_size` > 0.

Review (20.10.2026): gemergt.
