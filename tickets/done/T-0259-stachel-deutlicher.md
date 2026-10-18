---
id: T-0259
title: Stacheln größer und mit dunklem Rand zeichnen
project: zellenphase
priority: 4
---
## Ziel
Beim Ansehen (P-0004) waren Stacheln im normalen Spielbild kaum als Stachel zu erkennen: klein und blass. Sie werden länger, breiter und kräftiger gefärbt und bekommen einen dunklen Rand, bei der Spielerzelle wie bei den KI-Zellen. Die Trefferberechnung (`WeaponRules.SPIKE_LENGTH`) bleibt unverändert.

## Dateien
- `scripts/part_looks.gd`
- `scripts/player_cell.gd`
- `scripts/ai_cell.gd`
- `tests/test_part_looks.gd`

## Akzeptanzkriterien
- `scripts/part_looks.gd`: Farbe `"stachel": Color(1.0, 0.8, 0.3)` statt `Color(0.95, 0.85, 0.6)`; Form `"stachel": [Vector2(0.0, 0.16), Vector2(1.1, 0.0), Vector2(0.0, -0.16)]`.
- Neu in `scripts/part_looks.gd` (am Ende):
```gdscript
## Randfarbe eines Teils; durchsichtig (alpha 0), wenn das Teil keinen Rand hat.
const OUTLINES := {"stachel": Color(0.3, 0.15, 0.05, 0.95)}


static func outline(id: String) -> Color:
	return OUTLINES.get(id, Color(0, 0, 0, 0))


## Geschlossener Linienzug (erster Punkt am Ende wiederholt) für draw_polyline.
static func closed(points: PackedVector2Array) -> PackedVector2Array:
	var out := points.duplicate()
	if out.size() > 0:
		out.append(out[0])
	return out
```
- `scripts/player_cell.gd`, `_draw()`, im zweiten `for part in build.parts:` direkt nach der Zeile `draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))` (gleiche Einrückung):
```gdscript
			if PartLooks.outline(part["id"]).a > 0.0:
				draw_polyline(PartLooks.closed(PartLooks.placed(part, radius)), PartLooks.outline(part["id"]), maxf(1.0, radius * 0.06))
```
- `scripts/ai_cell.gd`: dasselbe direkt nach der Zeile 99 `draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))` (der Aufruf außerhalb des Antriebs-Zweigs).
- Sonst nichts ändern.

## Tests
- `tests/test_part_looks.gd`, `test_stachel_nach_aussen`: Erwartung auf `Vector2(0, 21)` ändern (10 + 1,1 × 10), Meldung „Stachel zeigt nach außen“ bleibt.
- Am Ende anhängen:
  - `test_stachel_rand`: `PartLooks.outline("stachel").a > 0.0` wahr; `PartLooks.outline("kiefer").a` ist `0.0`
  - `test_geschlossen`: `PartLooks.closed(PackedVector2Array([Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]))` hat 4 Punkte, der letzte ist `Vector2(1, 0)`; `PartLooks.closed(PackedVector2Array())` ist leer
  - `test_stachel_breiter`: `PartLooks.shape("stachel")[0]` ist `Vector2(0.0, 0.16)`

Review (17.10.2026): gemergt, nachgebessert: Einrückung der Tabellen und Leerzeilen zurückgestellt.
