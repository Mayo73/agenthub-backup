---
id: T-0291
title: Fische mit Rückenflosse und hellem Bauch
project: zellenphase
priority: 4
after: T-0290
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „schönere Fische“: Die Fische wirken bisher wie eine Kugel mit Brettchen. Eine Rückenflosse und ein heller Bauch (wie bei echten Fischen, Gegenschattierung) machen sie fischähnlicher. Die Rückenflosse wächst mit den Brustflossen-Stufen.

## Dateien
- `scripts/fish_model.gd`
- `tests/test_fish_model.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_model.gd`:
  - neue Variablen `var dorsal: MeshInstance3D` und `var belly: MeshInstance3D` unter `var jaw: MeshInstance3D`.
  - In `shape(b)` zwei Einträge ergänzen (Kommentar oberhalb mit erweitern: `dorsal = Höhe der Rückenflosse`):
    `"dorsal": 0.25 + 0.08 * b.level("flossen"),`
  - Neue statische Funktion unter `shape(b)`:
```gdscript
## Farbe des Bauchs: deutlich heller als der Rücken.
static func belly_color(color: Color) -> Color:
	return color.lightened(0.45)
```
  - In `rebuild(b)` direkt nach der Zeile `body.scale = size`:
```gdscript
	belly = add_part(self, "Belly", sphere(0.5), material(belly_color(b.color)), Vector3(0.0, -size.y * 0.12, 0.0))
	belly.scale = Vector3(size.x * 0.92, size.y * 0.8, size.z * 0.9)
	var d: float = s["dorsal"]
	dorsal = add_part(self, "Dorsal", box(Vector3(0.04, d, size.z * 0.35)), skin, Vector3(0.0, size.y * 0.5 + d * 0.35, size.z * 0.05))
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_model.gd` anhängen (dort legt `setup()` schon `model = FishModel.new()` an und `teardown()` gibt es frei; in den Tests unten steht `m` für `model`):
- `test_rueckenflosse`: `FishModel.shape(FishBuild.new())["dorsal"]` ist 0.25; mit Brustflossen auf Stufe 2: 0.41; ein neues Modell hat Kinder `"Dorsal"` und `"Belly"` (`has_node`)
- `test_rueckenflosse_waechst`: Modell mit `FishBuild.new()` → `(m.dorsal.mesh as BoxMesh).size.y` merken; `m.rebuild(b)` mit Brustflossen Stufe 3 → größer
- `test_bauch_heller`: `FishModel.belly_color(Color(0.2, 0.4, 0.3)).get_luminance() > Color(0.2, 0.4, 0.3).get_luminance()` wahr
- `test_neu_bauen_ohne_doppelte`: `m.rebuild(FishBuild.new())` zweimal → genau ein Kind `"Belly"` und ein `"Dorsal"` (über `get_children()` zählen)

Review (18.10.2026): gemergt.
