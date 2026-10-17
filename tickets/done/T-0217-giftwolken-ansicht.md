---
id: T-0217
title: Giftwolken sichtbar zeichnen (PoisonCloudView)
project: zellenphase
priority: 2
---
## Ziel
Die Giftwolken (`PoisonClouds`) wirken schon, sind aber unsichtbar. Eine neue Ansicht zeichnet sie als halbdurchsichtige grüne Kreise, die wachsen und verblassen (Abnahmekriterium 6: Giftwirkung direkt beobachtbar).

## Dateien
- `scripts/poison_cloud_view.gd` – neu
- `tests/test_poison_cloud_view.gd` – neu

## Akzeptanzkriterien
`scripts/poison_cloud_view.gd` genau so:
```gdscript
class_name PoisonCloudView
extends Node2D
## Zeichnet die Giftwolken aller Quellen (PoisonClouds) als grüne Kreise, die wachsen und verblassen.

const COLOR := Color(0.55, 0.85, 0.3)

## Quellen vom Typ PoisonClouds (Spielerzelle und KI-Zellen).
var sources: Array = []


## Deckkraft einer Wolke mit dem Alter age (Sekunden).
static func cloud_alpha(age: float) -> float:
    return 0.45 * (1.0 - clampf(age / PoisonClouds.LIFETIME, 0.0, 1.0))


## Radius einer Wolke mit dem Alter age: wächst von 60 % auf 100 % von PoisonClouds.RADIUS.
static func cloud_radius(age: float) -> float:
    return PoisonClouds.RADIUS * (0.6 + 0.4 * clampf(age / PoisonClouds.LIFETIME, 0.0, 1.0))


## Anzahl aller Wolken aus allen Quellen.
func cloud_count() -> int:
    var n := 0
    for src: PoisonClouds in sources:
        n += src.clouds.size()
    return n


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    for src: PoisonClouds in sources:
        for c: Dictionary in src.clouds:
            var col := COLOR
            col.a = cloud_alpha(c["age"])
            draw_circle(c["pos"], cloud_radius(c["age"]), col)
```
- Keine andere Datei ändern.

## Tests
`tests/test_poison_cloud_view.gd` mit `extends "res://tests/base_test.gd"`:
- `test_alpha`: `PoisonCloudView.cloud_alpha(0.0)` ist 0.45; `cloud_alpha(PoisonClouds.LIFETIME / 2.0)` ist 0.225; `cloud_alpha(PoisonClouds.LIFETIME)` ist 0.0; `cloud_alpha(10.0)` ist 0.0
- `test_radius`: `PoisonCloudView.cloud_radius(0.0)` ist `PoisonClouds.RADIUS * 0.6`; `cloud_radius(PoisonClouds.LIFETIME)` ist `PoisonClouds.RADIUS`; `cloud_radius(99.0)` ist `PoisonClouds.RADIUS`
- `test_zaehlen`: `var a := PoisonClouds.new()`, `a.emit(Vector2.ZERO)`; `var b := PoisonClouds.new()`, `b.emit(Vector2(50, 0))`, `b.cooldown = 0.0`, `b.emit(Vector2(90, 0))`; `var v := PoisonCloudView.new()`, `v.sources = [a, b]` → `v.cloud_count()` ist 3; am Ende `v.free()`
- `test_leer`: `var v := PoisonCloudView.new()` → `v.cloud_count()` ist 0; `v.free()`

Review (17.10.2026): gemergt.
