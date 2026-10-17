---
id: T-0257
title: Abwechslungsreichere Deko (Größe und Spiegelung)
project: drift
priority: 3
---
## Ziel
Beim Ansehen der Rennbilder wirkte die Deko gleichförmig: Alle Reifenstapel und Büsche sind gleich groß und gleich ausgerichtet. Jedes Deko-Element bekommt eine feste, von seiner Nummer abhängige Größe und Spiegelung, sodass die Strecke abwechslungsreicher aussieht und trotzdem bei jedem Start gleich.

## Dateien
- `scripts/track_decor.gd`
- `scripts/track.gd`
- `tests/test_track_decor.gd`

## Akzeptanzkriterien
- In `scripts/track_decor.gd` vor `## Deko einer Strecke: ...` einfügen:
```gdscript
## Größenfaktoren der Deko, reihum nach Nummer des Elements.
const SCALES := [1.0, 0.82, 1.18, 0.92, 1.08]


## Feste Abwandlung eines Deko-Elements: {"scale": float, "flip": bool}. Gleiche Nummer, gleiche Abwandlung.
static func variation(index: int) -> Dictionary:
	var i := absi(index)
	return {"scale": SCALES[i % SCALES.size()], "flip": i % 3 == 1}
```
- In `build(path)` bekommt jeder Eintrag zusätzlich die Schlüssel `"scale"` und `"flip"` aus `variation(items.size())` (also der Nummer, die der Eintrag in `items` bekommt). Beispiel für die Reifenstapel: `var v := variation(items.size())` und dann `items.append({"kind": Kind.TIRES, "position": q, "scale": v["scale"], "flip": v["flip"]})`; für die Bäume genauso. Den Kommentar über `build` auf `## Jeder Eintrag: {"kind": Kind, "position": Vector2, "scale": float, "flip": bool}.` anpassen.
- In `scripts/track.gd`, Funktion `_draw_decor()`, die Schleife `for item in decor:` so ändern, dass Größe und Spiegelung gelten:
```gdscript
	for item in decor:
		var p: Vector2 = item["position"]
		var s: float = item.get("scale", 1.0)
		var sx := -s if item.get("flip", false) else s
		if item["kind"] == TrackDecor.Kind.TIRES:
			draw_set_transform(p, 0.0, Vector2(sx, s))
			draw_texture_rect(TIRES_TEXTURE, Rect2(-TIRES_SIZE * 0.5, TIRES_SIZE), false)
		else:
			draw_set_transform(p, 0.0, Vector2(s, s))
			draw_circle(Vector2(8, 8), 40.0, Color(0, 0, 0, 0.25))
			draw_set_transform(p, 0.0, Vector2(sx, s))
			draw_texture_rect(TREE_TEXTURE, Rect2(-TREE_SIZE * 0.5, TREE_SIZE), false)
	draw_set_transform(Vector2.ZERO)
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_track_decor.gd` anhängen:
- `test_abwandlung`: `TrackDecor.variation(0)` ist `{"scale": 1.0, "flip": false}`; `TrackDecor.variation(1)["flip"]` ist `true`; `TrackDecor.variation(2)["scale"]` ist `1.18`; `TrackDecor.variation(5)["scale"]` ist `1.0`; `TrackDecor.variation(-1)["flip"]` ist `true`
- `test_deko_abgewandelt`: `var items := TrackDecor.build(square)` → jeder Eintrag hat die Schlüssel `"scale"` und `"flip"`; `items[0]["scale"]` ist `1.0`; mindestens ein Eintrag hat `"flip"` wahr und mindestens zwei verschiedene `"scale"`-Werte kommen vor
- `test_gleich_bei_jedem_start`: `TrackDecor.build(square)` zweimal aufrufen → beide Ergebnisse sind gleich (`==`)

Review (17.10.2026): gemergt.
