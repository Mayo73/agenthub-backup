---
id: T-0473
title: Symbol für Leerzustände und Leerzustand im Entdecken
project: sparring
priority: 2
after: T-0464, T-0466
---
## Ziel
Auftrag „Modernes Design“ (M9): Leere Bildschirme zeigen wie in modernen Apps ein großes Symbol über dem Hinweistext statt nur einer Textzeile. Hier entsteht der Baustein in `UiStyle` und sein erster Einsatz im Entdecken.

## Dateien
- `scripts/ui_style.gd` – neue statische Funktion `empty_icon` (vor `## Senkrechter Verlauf als Textur` einfügen)
- `scripts/discover_screen.gd` – Symbol über `empty_label`
- `tests/test_ui_style.gd` – Test ergänzen (bestehende nicht ändern)
- `tests/test_discover_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- `static func empty_icon(symbol: String) -> Label` mit `##`-Kommentar: `label(symbol, 96, ACCENT)`, `horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER`, `autowrap_mode = TextServer.AUTOWRAP_OFF`, gibt das Label zurück.
- `DiscoverScreen`: neue Variable `var empty_icon: Label` = `UiStyle.empty_icon("✦")`, direkt vor `empty_label` in `vbox` eingefügt.
- In `refresh()` ist `empty_icon.visible` immer gleich `empty_label.visible` (an beiden Stellen, an denen `empty_label.visible` gesetzt wird).
- Die Texte von `empty_label` bleiben genau gleich.

## Tests
- `tests/test_ui_style.gd`: `test_empty_icon`: `UiStyle.empty_icon("♥")` → `text` „♥“, `horizontal_alignment` CENTER, `get_theme_color("font_color")` gleich `UiStyle.ACCENT`; danach `free()`.
- `tests/test_discover_screen.gd`: `test_leer_mit_symbol`: Bildschirm aufbauen und alle Kandidaten mit `decide_pass()` überspringen, bis `current()` null ist → `empty_icon.visible` wahr, `empty_icon.text` „✦“. Solange noch ein Kandidat da ist, ist `empty_icon.visible` falsch.
