---
id: T-0468
title: Matchliste im neuen Stil
project: sparring
priority: 2
after: T-0466
---
## Ziel
Auftrag „Modernes Design“ (M9): Die Matchliste bekommt eine Überschrift, Abstand zum Rand und Zeilen als Karten mit weichem Schatten und größerem Porträt.

## Dateien
- `scripts/matches_screen.gd`
- `tests/test_matches_screen.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variable `var title_label: Label` = `UiStyle.label("Deine Matches", UiStyle.SIZE_TITLE)`, als erstes Kind von `box` (vor `empty_label`).
- `box` liegt in einem `MarginContainer` mit `UiStyle.GAP` Rand auf allen vier Seiten (`margin_left` usw.), der `MarginContainer` ist das Kind der `ScrollContainer` und hat `size_flags_horizontal = Control.SIZE_EXPAND_FILL`. `box` hat `separation` `UiStyle.GAP`.
- Zeilen-Knopf mit `UiStyle.row_button(row_text(state, m))` statt `UiStyle.button(...)`; der Text bleibt genau gleich.
- Avatar je Zeile `set_diameter(88)`.
- Beendete Matches bleiben abgeblendet (`modulate` 0.6).

## Tests
- `test_ueberschrift`: `title_label.text` ist „Deine Matches“, auch ohne Matches sichtbar.
- `test_zeile_als_karte`: mit einem Match (wie in `test_eine_zeile`) ist `(rows["m1"] as Button).alignment` LEFT und `(rows["m1"].get_theme_stylebox("normal") as StyleBoxFlat).shadow_size` > 0.
Review (20.10.2026): gemergt, nachgebessert: Ränder per add_theme_constant_override statt set(), Test test_rand.
