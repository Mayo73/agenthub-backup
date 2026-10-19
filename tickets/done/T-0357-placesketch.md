---
id: T-0357
title: PlaceSketch – Ortsart erkennen und schematische Formen liefern
project: sparring
priority: 3
---
## Ziel
Meilenstein „Ortsskizze“ (Lastenheft, Kann: „Schematische, selbst erstellte Ortsdarstellung ohne externen Kartendienst“): Aus dem Ortstext eines Treffvorschlags wird eine Ortsart erkannt (Park, Strand …), und zu jeder Art gibt es eine Liste einfacher Formen, die später gezeichnet werden. Reine Logik, kein Netzwerk, keine Karte.

## Dateien
- `scripts/place_sketch.gd` – neu, Klasse `PlaceSketch`
- `tests/test_place_sketch.gd` – neu

## Akzeptanzkriterien
`class_name PlaceSketch`, `extends RefCounted`, nur Konstanten und statische Funktionen:
- `const KINDS: Array[String] = ["Park", "Wiese", "Strand", "Sportplatz", "Wald", "Draußen"]`
- `const RULES: Array = [["sportplatz", "Sportplatz"], ["park", "Park"], ["wiese", "Wiese"], ["rasen", "Wiese"], ["strand", "Strand"], ["ufer", "Strand"], ["see", "Strand"], ["wald", "Wald"], ["platz", "Sportplatz"]]`
- `static func kind_for(place: String) -> String`: Text klein schreiben (`to_lower()`), die **erste** Regel aus `RULES` (in dieser Reihenfolge), deren Stichwort im Text vorkommt, bestimmt die Art; sonst (auch bei leerem Text) `"Draußen"`.
- `static func shapes(kind: String) -> Array[Dictionary]`: Formen mit relativen Koordinaten (0–1, bezogen auf Breite und Höhe der Fläche). Jede Form ist entweder `{"type": "rect", "pos": Vector2, "size": Vector2, "color": Color}` oder `{"type": "circle", "pos": Vector2, "radius": float, "color": Color}` (`radius` relativ zur Breite). Die **erste** Form ist immer der Hintergrund `rect` mit `pos` `Vector2(0, 0)` und `size` `Vector2(1, 1)`. Genau diese Formen:
  - „Park“ (5): Hintergrund `Color(0.25, 0.55, 0.30)`; Weg `rect` pos `(0, 0.45)` size `(1, 0.1)` `Color(0.80, 0.72, 0.55)`; drei Bäume `circle` radius 0.08 `Color(0.15, 0.40, 0.20)` bei `(0.2, 0.25)`, `(0.75, 0.2)`, `(0.6, 0.75)`
  - „Wiese“ (3): Hintergrund `Color(0.40, 0.70, 0.35)`; zwei Blumen `circle` radius 0.03 `Color(0.95, 0.85, 0.30)` bei `(0.3, 0.3)` und `(0.7, 0.6)`
  - „Strand“ (2): Hintergrund `Color(0.90, 0.82, 0.60)`; Wasser `rect` pos `(0, 0)` size `(1, 0.4)` `Color(0.25, 0.50, 0.80)`
  - „Sportplatz“ (3): Hintergrund `Color(0.30, 0.60, 0.30)`; Feld `rect` pos `(0.1, 0.1)` size `(0.8, 0.8)` `Color(0.35, 0.68, 0.35)`; Mittelkreis `circle` bei `(0.5, 0.5)` radius 0.1 `Color(0.95, 0.95, 0.95)`
  - „Wald“ (6): Hintergrund `Color(0.18, 0.40, 0.22)`; fünf Bäume `circle` radius 0.1 `Color(0.10, 0.30, 0.15)` bei `(0.2, 0.2)`, `(0.5, 0.3)`, `(0.8, 0.2)`, `(0.3, 0.7)`, `(0.7, 0.75)`
  - „Draußen“ (2): Himmel als Hintergrund `Color(0.40, 0.55, 0.70)`; Boden `rect` pos `(0, 0.6)` size `(1, 0.4)` `Color(0.35, 0.60, 0.35)`
  - unbekannte Art → die Formen von „Draußen“
- `static func caption(kind: String) -> String`: `"Skizze: %s (schematisch, keine Karte)" % kind`; bei „Draußen“ `"Skizze: draußen (schematisch, keine Karte)"`.

## Tests
`tests/test_place_sketch.gd`:
- `test_erkennung`: „Stadtpark, Wiese am Teich“ → „Park“; „Liegewiese“ → „Wiese“; „Sportplatz an der Schule“ → „Sportplatz“; „Bolzplatz“ → „Sportplatz“; „Waldweg“ → „Wald“; „Rheinufer“ → „Strand“
- `test_gross_klein`: „STRAND“ → „Strand“
- `test_unbekannt`: „“ → „Draußen“; „Hinterhof“ → „Draußen“
- `test_anzahl`: `shapes("Park").size()` 5, Wiese 3, Strand 2, Sportplatz 3, Wald 6, Draußen 2, `shapes("Mond").size()` 2
- `test_hintergrund_zuerst`: für jede Art in `KINDS`: erste Form hat `type` „rect“, `pos` `Vector2.ZERO`, `size` `Vector2.ONE`
- `test_im_rahmen`: für jede Art: alle `pos`-Werte haben x und y zwischen 0 und 1
- `test_beschriftung`: `caption("Park")` „Skizze: Park (schematisch, keine Karte)“; `caption("Draußen")` „Skizze: draußen (schematisch, keine Karte)“

Review (18.10.2026): gemergt.
