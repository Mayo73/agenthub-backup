---
id: T-0470
title: Treffen-Bildschirm in Abschnitts-Karten
project: sparring
priority: 2
after: T-0466
---
## Ziel
Auftrag „Modernes Design“ (M9): Der Treffen-Bildschirm wird übersichtlicher: Rand, runder Zurück-Knopf, Status oben in einer Karte, Eingabefelder abgerundet.

## Dateien
- `scripts/meeting_screen.gd`
- `tests/test_meeting_screen.gd` – Tests ergänzen (bestehende nicht ändern, `test_reihenfolge` muss weiter bestehen: vorher lesen!)

## Akzeptanzkriterien
- `vbox` liegt in einem `MarginContainer` mit `UiStyle.GAP` Rand auf allen Seiten (`size_flags_horizontal = Control.SIZE_EXPAND_FILL`, Kind der `ScrollContainer`), `vbox` hat `separation` 12; die `ScrollContainer` hat `horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED`.
- `back_button` = `UiStyle.round_button("‹", UiStyle.TEXT, 64)`.
- Neue Variable `var status_card: PanelContainer` mit Stilbox `"panel"` = `UiStyle.card_panel(UiStyle.CARD, UiStyle.RADIUS)`; darin ein `VBoxContainer` mit `status_label` und `summary_label` (statt direkt in `vbox`). Die Karte steht an der Stelle, an der vorher `status_label` stand.
- Jedes `LineEdit` aus `_line_edit(...)` bekommt `UiStyle.style_input(...)`; jedes `OptionButton` aus `_picker(...)` `UiStyle.style_option(...)`.

## Tests
- `test_status_karte`: `status_label.get_parent().get_parent() == status_card`, `(status_card.get_theme_stylebox("panel") as StyleBoxFlat).shadow_size` > 0.
- `test_felder_gestaltet`: `place_edit.custom_minimum_size.y` 72, `back_button.text` „‹“.