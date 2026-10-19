---
id: T-0352
title: DemoData – Merkmale der acht Testprofile
project: sparring
priority: 3
after: T-0351
---
## Ziel
Meilenstein „Profilmerkmale“: Die acht fiktiven Testprofile bekommen Gewichtsklasse, Trainingstage und Ausrüstung (Felder aus T-0351), damit Karten und Treffen sie zeigen können.

## Dateien
- `scripts/demo_data.gd` – je Profil die drei Schlüssel im Dictionary für `SparProfile.from_dict` ergänzen
- `tests/test_demo_data.gd` – Tests anhängen

## Akzeptanzkriterien
In `DemoData.profiles()` bei jedem Profil zusätzlich (sonst nichts ändern):

| ID | `weight_class` | `days` | `equipment` |
|---|---|---|---|
| p01 | 1 | `["Di", "Do", "Sa"]` | `["Mundschutz", "Matte"]` |
| p02 | 2 | `["Mo", "Mi", "Fr"]` | `["Handschuhe", "Schienbeinschoner", "Mundschutz"]` |
| p03 | 0 | `["Sa", "So"]` | `["Handschuhe", "Pratzen"]` |
| p04 | 1 | `["Mi", "Sa"]` | `[]` |
| p05 | 0 | `["Mo", "Do"]` | `["Matte"]` |
| p06 | 1 | `["Di", "Fr", "So"]` | `["Handschuhe", "Schienbeinschoner"]` |
| p07 | 2 | `["Sa"]` | `["Mundschutz", "Matte"]` |
| p08 | 2 | `["Mo", "Di", "Mi", "Do", "Fr"]` | `["Handschuhe", "Mundschutz", "Pratzen"]` |

## Tests
`tests/test_demo_data.gd` anhängen:
- `test_merkmale_vollstaendig`: jedes Profil hat `weight_class` zwischen 0 und 2 und mindestens einen Tag in `days`
- `test_merkmale_alex`: `profiles()[0]` → `weight_class` 1, `days` `["Di", "Do", "Sa"]`, `equipment` `["Mundschutz", "Matte"]`
- `test_merkmale_sam`: `profiles()[1]` → `weight_name()` „Schwer (über 84 kg)“, `days` `["Mo", "Mi", "Fr"]`
- `test_ohne_ausruestung`: `profiles()[3]` (Jonas) → `equipment` leer

Review (18.10.2026): gemergt.
