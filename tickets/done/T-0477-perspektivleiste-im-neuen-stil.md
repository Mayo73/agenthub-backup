---
id: T-0477
title: Demo-Perspektivleiste im neuen Stil
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9): Die Leiste „DEMO-PERSPEKTIVE“ oben bekommt Innenabstand, eine dünne gelbe Linie als Demo-Kennzeichen und eine abgerundete Auswahl wie die übrigen Auswahlfelder.

## Dateien
- `scripts/perspective_bar.gd`
- `tests/test_perspective_bar.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Stilbox `"panel"` = `UiStyle.panel(UiStyle.CARD, 0)` mit `border_width_bottom = 3`, `border_color = UiStyle.DEMO`, `content_margin_left/right` = `UiStyle.GAP` und `content_margin_top/bottom` = 8.
- `UiStyle.style_option(picker)` nach dem Anlegen; `fit_to_longest_item = false` und `clip_text = true` bleiben erhalten (nach `style_option` noch einmal setzen).
- `avatar.set_diameter(64)`.
- Text und Farbe von `tag_label` bleiben gleich (Demo-Kennzeichnung).

## Tests
- `test_demolinie`: `(bar.get_theme_stylebox("panel") as StyleBoxFlat).border_width_bottom` 3 und `border_color` `UiStyle.DEMO`.
- `test_auswahl_abgerundet`: `(bar.picker.get_theme_stylebox("normal") as StyleBoxFlat).corner_radius_top_left` > 0; `bar.picker.clip_text` wahr.

Review (20.10.2026): gemergt.
