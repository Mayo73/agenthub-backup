---
id: T-0229
title: Drei zusätzliche Zellarten (Flimmerling, Panzerling, Schwebqualle)
project: zellenphase
priority: 2
---
## Ziel
Das Lastenheft erlaubt zusätzliche Zelltypen („Kann“). Drei neue Arten füllen dünn besetzte Größenabschnitte: ein schneller Flimmerling in Abschnitt 0, ein bestachelter Panzerling in Abschnitt 2 und eine große, harmlose Schwebqualle in Abschnitt 4, die für die große Spielerzelle Beute ist.

## Dateien
- `scripts/species_catalog.gd` – drei Einträge in `SPECIES`
- `scripts/species_parts.gd` – drei Einträge in `PARTS`
- `scripts/part_drops.gd` – drei Einträge in `DROPS`
- `docs/zelltypen.md` – Tabellenzeilen und Abschnitte für die neuen Arten
- `tests/test_species_catalog.gd` – zwei erwartete Werte anpassen

## Akzeptanzkriterien
- `scripts/species_catalog.gd`, in `SPECIES` an genau diesen Stellen einfügen (die Reihenfolge der Tabelle bestimmt `ids()`):
  - direkt nach der Zeile `"blasenling": …`:
    ```gdscript
    	"flimmerling": {"name": "Flimmerling", "stage": 0, "diet": Diet.PFLANZENFRESSER, "behavior": "scheu", "speed": 140.0, "hp": 15.0, "damage": 0.0, "color": Color(0.55, 0.85, 0.95), "pattern": "punkte", "stretch": 1.25},
    ```
  - direkt nach der Zeile `"zitterzelle": …`:
    ```gdscript
    	"panzerling": {"name": "Panzerling", "stage": 2, "diet": Diet.PFLANZENFRESSER, "behavior": "scheu", "speed": 70.0, "hp": 110.0, "damage": 0.0, "color": Color(0.55, 0.45, 0.35), "pattern": "flecken", "stretch": 0.95},
    ```
  - direkt nach der Zeile `"riesenschlund": …`:
    ```gdscript
    	"schwebqualle": {"name": "Schwebqualle", "stage": 4, "diet": Diet.PFLANZENFRESSER, "behavior": "scheu", "speed": 50.0, "hp": 250.0, "damage": 0.0, "color": Color(0.9, 0.7, 0.85), "pattern": "keins", "stretch": 0.8},
    ```
  - Den Kommentar `## Die acht anderen Zellarten …` in `## Die anderen Zellarten im Ökosystem, verteilt über die fünf Größenabschnitte.` ändern.
- `scripts/species_parts.gd`, in `PARTS` am Ende (nach `"riesenschlund": …`) anfügen:
  ```gdscript
  	"flimmerling": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}],
  	"panzerling": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "stachel", "pos": Vector2(-0.7, 0.7), "angle": 0.0}, {"id": "stachel", "pos": Vector2(-0.7, -0.7), "angle": 0.0}],
  	"schwebqualle": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(-1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, 1), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, -1), "angle": 0.0}],
  ```
- `scripts/part_drops.gd`, in `DROPS` am Ende anfügen: `"flimmerling": "geissel",`, `"panzerling": "stachel",`, `"schwebqualle": "wimpern",`
- `docs/zelltypen.md`:
  - Im ersten Absatz „Alle acht Arten“ durch „Alle elf Arten“ ersetzen.
  - In der Tabelle je eine Zeile ergänzen (gleiches Spaltenformat wie die anderen):
    - `| Flimmerling | 0 | Pflanzenfresser | flieht, sucht Pflanzen, schnell (140 Pixel/s) | hellblau, Punkte, gestreckt, Filtermaul, Geißel | 0 (harmlos) |`
    - `| Panzerling | 2 | Pflanzenfresser | flieht, sucht Pflanzen, langsam, 110 Gesundheit | braun, Flecken, Filtermaul, zwei Stacheln nach hinten | 0 (beißt nicht) |`
    - `| Schwebqualle | 4 | Pflanzenfresser | flieht, sucht Pflanzen, sehr langsam (50 Pixel/s), 250 Gesundheit | blassrosa, ohne Muster, gedrungen, Filtermaul, Wimpern rundum | 0 (harmlos) |`
  - Vor dem Abschnitt `## Vorführung` drei Abschnitte einfügen, je mit 2–3 Sätzen nach den Werten oben: `## Flimmerling`, `## Panzerling`, `## Schwebqualle`. Beim Flimmerling erwähnen, dass er schon ab Abschnitt 1 vor der Spielerzelle flieht; bei der Schwebqualle, dass sie im Abschnitt 4 eine große, aber wehrlose Beute ist.
- `tests/test_species_catalog.gd`:
  - In `test_acht_arten` die Zeile `check_eq(ids.size(), 8, "acht Arten")` durch `check_eq(ids.size(), 11, "elf Arten")` ersetzen (Funktionsname bleibt).
  - In `test_nahe_abschnitte` die beiden Listen ersetzen: `var near0: Array[String] = ["blasenling", "flimmerling", "schnapper", "stachelkugel"]` und `var near4: Array[String] = ["weidezelle", "hornjaeger", "riesenschlund", "schwebqualle"]`.
- Keine Tests löschen oder umbenennen, keine anderen Dateien ändern.

## Tests
`tests/test_species_catalog.gd` wie oben angepasst; neu angehängt:
- `test_neue_arten`: `SpeciesCatalog.radius_of("flimmerling")` ist 12.0; `SpeciesCatalog.radius_of("panzerling")` ist 27.0; `SpeciesCatalog.radius_of("schwebqualle")` ist 60.0; `SpeciesCatalog.data("schwebqualle")["damage"]` ist 0.0; `PartDrops.DROPS["panzerling"]` ist `"stachel"`; `SpeciesParts.parts_of("schwebqualle").size()` ist 4

Review (17.10.2026): gemergt.
