---
id: T-0258
title: Asphalt und Rasen mit Textur zeichnen
project: drift
priority: 3
after: A-0014, A-0015, T-0257
---
## Ziel
Die Rennansicht wirkte flach (einfarbiger Asphalt und Rasen) im Vergleich zum gemalten Titelbild. Asphalt und Rasen bekommen kachelbare Texturen (Medien-Aufträge A-0014 und A-0015, Dateien liegen schon im Projekt).

## Dateien
- `scripts/track.gd`
- `tests/test_track_loading.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/track.gd` unter `const TIRES_SIZE := ...`:
```gdscript
const ROAD_TEXTURE := preload("res://assets/track/asphalt.png")
const GRASS_TEXTURE := preload("res://assets/track/grass.png")
## Kantenlänge einer Texturkachel in Weltpixeln.
const TEXTURE_TILE := 256.0
## So weit reicht der Rasen über die Strecke hinaus.
const GRASS_MARGIN := 4000.0
```
- Neue statische Funktion (vor `_fill`):
```gdscript
## Texturkoordinaten für eine Fläche: eine Kachel je TEXTURE_TILE Weltpixel.
static func tile_uvs(polygon: PackedVector2Array) -> PackedVector2Array:
	var uvs := PackedVector2Array()
	for p in polygon:
		uvs.append(p / TEXTURE_TILE)
	return uvs


## Rechteck um die Strecke, um GRASS_MARGIN vergrößert (für den Rasen außen).
static func grass_rect(outline: PackedVector2Array) -> PackedVector2Array:
	if outline.is_empty():
		return PackedVector2Array()
	var box := Rect2(outline[0], Vector2.ZERO)
	for p in outline:
		box = box.expand(p)
	box = box.grow(GRASS_MARGIN)
	return PackedVector2Array([box.position, Vector2(box.end.x, box.position.y), box.end, Vector2(box.position.x, box.end.y)])
```
- `_fill(polygon, color)` bekommt einen dritten Parameter `texture: Texture2D = null`; mit Textur zeichnet es `draw_colored_polygon(polygon, Color.WHITE, tile_uvs(polygon), texture)`, sonst wie bisher.
- In `_ready()` als erste Zeile `texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED`.
- In `_draw()` die beiden `_fill`-Zeilen ersetzen durch:
```gdscript
	var outer := path.outline(width * 0.5)
	_fill(grass_rect(outer), grass_color, GRASS_TEXTURE)
	_fill(outer, road_color, ROAD_TEXTURE)
	_fill(path.outline(-width * 0.5), grass_color, GRASS_TEXTURE)
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_track_loading.gd` anhängen (Track-Skript über `load("res://scripts/track.gd")`, statische Funktionen darüber aufrufen):
- `test_kachel_uvs`: `tile_uvs(PackedVector2Array([Vector2(256, 512), Vector2(-128, 0)]))` ergibt `[Vector2(1, 2), Vector2(-0.5, 0)]`
- `test_rasen_rechteck`: `grass_rect(PackedVector2Array([Vector2(0, 0), Vector2(100, 50)]))` hat 4 Punkte, der erste ist `Vector2(-4000, -4000)`, der dritte `Vector2(4100, 4050)`; `grass_rect(PackedVector2Array())` ist leer
- `test_texturen_geladen`: Track-Skript `ROAD_TEXTURE` und `GRASS_TEXTURE` sind nicht `null`; eine instanziierte Strecke (`load("res://scripts/track.gd").new()`, an die Wurzel hängen, danach `free()`) hat `texture_repeat == CanvasItem.TEXTURE_REPEAT_ENABLED`

Review (17.10.2026): gemergt.
