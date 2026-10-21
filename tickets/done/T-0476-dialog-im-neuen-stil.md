---
id: T-0476
title: Rückfrage-Dialog im neuen Stil
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9): Der Rückfrage-Dialog (z. B. „Demo zurücksetzen?“) wird eine schwebende Karte mit weichem Schatten, Innenabstand und größerem Text.

## Dateien
- `scripts/confirm_dialog.gd`
- `tests/test_confirm_dialog.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- `shade.color = Color(0, 0, 0, 0.7)`.
- Stilbox `"panel"` von `box` = `UiStyle.card_panel(UiStyle.CARD, UiStyle.RADIUS_CARD)`; zusätzlich `content_margin_left/right/top/bottom` dieser Stilbox auf 32 setzen.
- `vbox` hat `separation` 24, die Knopfzeile `hbox` `separation` `UiStyle.GAP`.
- `question_label` mit Schriftgröße 34, `horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER`, `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`.
- `cancel_button` = `UiStyle.button("Abbrechen", UiStyle.RAISED)`; `ok_button` bleibt `UiStyle.button("Ja", UiStyle.PASS)`.
- Signale und das Verhalten von `ask`, `cancel` bleiben unverändert.

## Tests
- `test_karte_mit_schatten`: `(dialog.box.get_theme_stylebox("panel") as StyleBoxFlat).shadow_size` > 0 und `content_margin_left` 32.
- `test_frage_zentriert`: `dialog.question_label.horizontal_alignment` CENTER, `dialog.question_label.get_theme_font_size("font_size")` 34.

Review (20.10.2026): gemergt.
