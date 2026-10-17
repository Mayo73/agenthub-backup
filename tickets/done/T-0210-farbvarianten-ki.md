---
id: T-0210
title: KI-Zellen bekommen ihre Farbvariante
project: zellenphase
priority: 3
after: T-0197, T-0209
---
## Ziel
KI-Zellen derselben Art unterscheiden sich leicht in der Farbe (`ColorVariants`). Die Variante hängt von der Startlage ab; eine Zelle bei (0, 0) behält genau die Farbe ihrer Art.

## Dateien
- `scripts/ai_cell.gd`
- `tests/test_ai_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- In `scripts/ai_cell.gd`, Funktion `setup(id, pos)`, direkt nach der Zeile `look = SpeciesCatalog.look_of(id)`:
```gdscript
	look.color = ColorVariants.vary(look.color, ColorVariants.seed_for(pos))
```
- Sonst nichts ändern (die Variable `color` für Maul und Stacheln bleibt die Farbe der Art).

## Tests
In `tests/test_ai_cell.gd` anhängen; jeder Test legt seine Zellen selbst an und gibt sie am Ende mit `free()` frei:
- `test_farbe_bei_null`: `var c := AiCell.new()`, `c.setup("schnapper", Vector2.ZERO)` → `c.look.color.is_equal_approx(SpeciesCatalog.look_of("schnapper").color)` wahr
- `test_farbvariante`: `var c := AiCell.new()`, `c.setup("schnapper", Vector2(100, 0))` → `var art := SpeciesCatalog.look_of("schnapper").color`; `c.look.color.is_equal_approx(ColorVariants.vary(art, ColorVariants.seed_for(Vector2(100, 0))))` wahr; `c.look.color.is_equal_approx(art)` falsch; `c.color.is_equal_approx(SpeciesCatalog.data("schnapper")["color"])` wahr
- `test_gleiche_lage_gleiche_farbe`: zwei Zellen `a` und `b`, beide `setup("blasenling", Vector2(250, 40))` → `a.look.color.is_equal_approx(b.look.color)` wahr

Review (17.10.2026): gemergt.
