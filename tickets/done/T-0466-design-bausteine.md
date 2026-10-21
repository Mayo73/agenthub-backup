---
id: T-0466
title: Neue UiStyle-Bausteine für Reiter, Listenzeilen, Sprechblasen und Eingabefelder
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9): Die Musterkarte ist freigegeben (P-0013), jetzt wird der Stil auf die übrigen Bildschirme übertragen. Dafür entstehen hier vier Bausteine in `UiStyle`, die die Folgetickets verwenden.

## Dateien
- `scripts/ui_style.gd` – vier neue statische Funktionen (vor `## Senkrechter Verlauf als Textur` einfügen)
- `tests/test_ui_style.gd` – neu

## Akzeptanzkriterien
- `static func icon_tab(symbol: String, text: String) -> Button`: ruft `tab_button(symbol + "\n" + text)` auf, setzt `custom_minimum_size = Vector2(0, 104)` und `add_theme_font_size_override("font_size", SIZE_SMALL)`, gibt den Knopf zurück. Aktive Reiter bleiben wie bei `tab_button` hervorgehoben.
- `static func row_button(text: String) -> Button`: wie `button(text)`, aber `alignment = HORIZONTAL_ALIGNMENT_LEFT`, `custom_minimum_size = Vector2(0, 104)`, Zustände über `_states(b, CARD, RADIUS)` und zusätzlich die Stilbox `"normal"` ersetzt durch `card_panel(CARD, RADIUS)` (weicher Schatten).
- `static func bubble(text: String, mine: bool) -> Label`: `label(text, SIZE_NORMAL, TEXT)`, Stilbox `"normal"` = `panel(ACCENT if mine else RAISED, 22)`, `custom_minimum_size = Vector2(480, 0)`, `horizontal_alignment` RIGHT bei `mine`, sonst LEFT; `size_flags_horizontal` `Control.SIZE_SHRINK_END` bei `mine`, sonst `Control.SIZE_SHRINK_BEGIN`.
- `static func style_input(e: LineEdit) -> void`: `custom_minimum_size = Vector2(0, 72)`, Schriftgröße `SIZE_NORMAL`, `font_color` `TEXT`, `font_placeholder_color` `MUTED`, Stilboxen `"normal"` = `panel(RAISED, RADIUS)` und `"focus"` = `panel(RAISED, RADIUS)` mit `set_border_width_all(2)` und `border_color = ACCENT`, `"read_only"` = `panel(CARD, RADIUS)`.
- Jede Funktion bekommt einen `##`-Kommentar.

## Tests
`tests/test_ui_style.gd` (`extends "res://tests/base_test.gd"`, erzeugte Nodes am Ende jedes Tests mit `free()` freigeben):
- `test_icon_tab`: `UiStyle.icon_tab("♥", "Matches")` → `text` ist `"♥\nMatches"`, `custom_minimum_size.y` 104, `get_theme_stylebox("disabled")` ist `StyleBoxFlat` mit `border_width_top` 5.
- `test_row_button`: `UiStyle.row_button("Sam")` → `alignment` LEFT, `custom_minimum_size.y` 104, `(get_theme_stylebox("normal") as StyleBoxFlat).shadow_size` > 0.
- `test_bubble`: `UiStyle.bubble("Hi", true)` → `horizontal_alignment` RIGHT, `size_flags_horizontal` `Control.SIZE_SHRINK_END`, `(get_theme_stylebox("normal") as StyleBoxFlat).bg_color` `UiStyle.ACCENT`; `UiStyle.bubble("Hi", false)` → LEFT, `SIZE_SHRINK_BEGIN`, `bg_color` `UiStyle.RAISED`.
- `test_style_input`: `LineEdit.new()`, `UiStyle.style_input(e)` → `custom_minimum_size.y` 72, `(e.get_theme_stylebox("focus") as StyleBoxFlat).border_color` `UiStyle.ACCENT`.
Review (20.10.2026): gemergt.
