---
id: T-0422
title: MaterialPresets – einfache 3D-Materialien mit geprüften Parametern
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Muss 3: Materialien in 3D; Muss 9: Materialparameter vorschlagen und nachvollziehbar ändern): Fertige Materialvorlagen und eine Prüfung der Parameter, als JSON-fähige Daten für Editor und Agenten.

## Dateien
- `core/material_presets.gd` – neu, Klasse `MaterialPresets`
- `tests/test_material_presets.gd` – neu

## Akzeptanzkriterien
`class_name MaterialPresets`, `extends RefCounted`, nur statische Funktionen. Ein Material ist `{"albedo": [r, g, b], "roughness": float, "metallic": float, "emission": float}` (Farbwerte 0–1).
- Vorlagen: `"holz"` `{[0.55, 0.36, 0.2], 0.8, 0.0, 0.0}`, `"metall"` `{[0.7, 0.7, 0.72], 0.3, 1.0, 0.0}`, `"stein"` `{[0.5, 0.5, 0.5], 0.95, 0.0, 0.0}`, `"leuchte"` `{[1.0, 0.9, 0.6], 0.5, 0.0, 2.0}` (Reihenfolge: albedo, roughness, metallic, emission)
- `static func names() -> Array[String]`: sortiert
- `static func get_preset(name: String) -> Dictionary`: tiefe Kopie oder `{}`
- `static func validate(material: Dictionary) -> Array[String]`, Reihenfolge: `albedo` fehlt oder hat nicht 3 Zahlen zwischen 0 und 1 → `"albedo braucht drei Werte zwischen 0 und 1"`; `roughness` außerhalb 0–1 → `"roughness muss zwischen 0 und 1 liegen"`; `metallic` ebenso; `emission` außerhalb 0–16 → `"emission muss zwischen 0 und 16 liegen"`; fehlende Zahlenwerte gelten als 0
- `static func blend(a: Dictionary, b: Dictionary, t: float) -> Dictionary`: alle Werte linear gemischt (`lerpf`), `t` auf 0–1 begrenzt
- `static func to_color(material: Dictionary) -> Color`: `Color(r, g, b)`

## Tests
`tests/test_material_presets.gd`:
- `test_namen`: `names()` ist `["holz", "leuchte", "metall", "stein"]`
- `test_vorlage`: `get_preset("metall")["metallic"]` 1.0; `get_preset("glas")` leer
- `test_kopie`: `var m := get_preset("holz")`, `m["roughness"] = 0.1` → `get_preset("holz")["roughness"]` weiter 0.8
- `test_pruefen`: `validate(get_preset("stein"))` leer; `validate({"albedo": [1, 2, 0], "roughness": 0.5, "metallic": 2.0})` ist `["albedo braucht drei Werte zwischen 0 und 1", "metallic muss zwischen 0 und 1 liegen"]`
- `test_mischen`: `blend(get_preset("holz"), get_preset("metall"), 0.5)["metallic"]` 0.5; `blend(..., 2.0)["roughness"]` 0.3
- `test_farbe`: `to_color(get_preset("stein"))` ist `Color(0.5, 0.5, 0.5)`
