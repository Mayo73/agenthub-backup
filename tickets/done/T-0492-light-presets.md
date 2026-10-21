---
id: T-0492
title: LightPresets – einfache Beleuchtung für 3D-Szenen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Muss 3: „Kameras, einfache Beleuchtung und Materialien in 3D“): Fertige Lichteinstellungen als JSON-fähige Daten, wie `MaterialPresets` für Materialien.

## Dateien
- `core/light_presets.gd` – neu, Klasse `LightPresets`
- `tests/test_light_presets.gd` – neu

## Akzeptanzkriterien
`class_name LightPresets`, `extends RefCounted`, nur statische Funktionen. Vorher `core/material_presets.gd` lesen und den Aufbau übernehmen (Farben dort genauso ablegen wie bei den Materialien).
- Ein Licht ist ein Dictionary: `"kind"` (`"sonne"` = gerichtetes Licht oder `"lampe"` = Punktlicht), `"color"`, `"energy"` (float), `"rotation"` (Array aus 3 Zahlen, Grad; bei Lampen `[0, 0, 0]`), `"range"` (float, nur Lampen sinnvoll, bei Sonne 0.0), `"shadows"` (bool)
- Vorlagen `"mittag"` (Sonne, weiß, Energie 1.2, Rotation `[-60, 30, 0]`, Schatten), `"abend"` (Sonne, warmes Orange, 0.7, `[-15, 60, 0]`, Schatten), `"innen"` (Lampe, warmweiß, 1.0, Reichweite 8.0, ohne Schatten)
- `static func names() -> Array[String]`: sortiert
- `static func get_preset(name: String) -> Dictionary`: Kopie (`duplicate(true)`), unbekannt → `{}`
- `static func validate(light: Dictionary) -> Array[String]`: Meldungen auf Deutsch für: unbekannte Art (`"Art %s gibt es nicht"`), Energie < 0 oder > 16 (`"Energie muss zwischen 0 und 16 liegen"`), Rotation nicht 3 Zahlen, Lampe mit Reichweite ≤ 0
- `static func energy_at(light: Dictionary, distance: float) -> float`: Sonne → `energy` unabhängig vom Abstand; Lampe → `energy * clampf(1.0 - distance / range, 0.0, 1.0)`

## Tests
`tests/test_light_presets.gd`:
- `test_namen`: `names()` ist `["abend", "innen", "mittag"]`
- `test_gueltig`: alle drei Vorlagen ergeben bei `validate` eine leere Liste
- `test_fehler`: `validate({"kind": "laser", "energy": 20.0, "rotation": [0, 0], "range": 0.0, "shadows": false})` hat mindestens 3 Meldungen
- `test_kopie`: Änderung an `get_preset("mittag")["energy"]` ändert eine neue `get_preset("mittag")` nicht
- `test_abstand`: `energy_at(get_preset("innen"), 4.0)` ungefähr 0.5, bei 10.0 → 0.0; `energy_at(get_preset("mittag"), 100.0)` 1.2

Review (2026-10-21): gemergt.
