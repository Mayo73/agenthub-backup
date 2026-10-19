---
id: T-0351
title: SparProfile – Gewichtsklasse, Verfügbarkeit und Ausrüstung
project: sparring
priority: 3
after: T-0322
---
## Ziel
Meilenstein „Profilmerkmale“ (Lastenheft, Kann: „Weitere rein fiktive Profilmerkmale wie Gewichtsklasse, Verfügbarkeit und vorhandene Ausrüstung“): `SparProfile` bekommt drei neue Felder, die gespeichert und geladen werden. Alte Spielstände ohne diese Felder laden weiter.

## Dateien
- `scripts/spar_profile.gd` – neue Konstanten, Felder, `weight_name()`, `to_dict()`/`from_dict()` erweitern
- `tests/test_spar_profile.gd` – Tests anhängen

## Akzeptanzkriterien
In `SparProfile`:
- `const WEIGHT_CLASSES: Array[String] = ["Leicht (bis 66 kg)", "Mittel (66–84 kg)", "Schwer (über 84 kg)"]`
- `const DAYS: Array[String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]`
- `const EQUIPMENT: Array[String] = ["Handschuhe", "Schienbeinschoner", "Mundschutz", "Matte", "Pratzen"]`
- `var weight_class := -1` (-1 = keine Angabe, sonst Index in `WEIGHT_CLASSES`)
- `var days: Array[String] = []` (Trainingstage, nur Werte aus `DAYS`)
- `var equipment: Array[String] = []` (nur Werte aus `EQUIPMENT`)
- `func weight_name() -> String`: `"keine Angabe"` bei -1 oder ungültigem Index, sonst `WEIGHT_CLASSES[weight_class]`
- `to_dict()` enthält zusätzlich `weight_class`, `days`, `equipment` (Arrays als Kopie).
- `from_dict(d)`: `weight_class` mit `int(...)` (fehlt → -1, außerhalb 0–2 → -1); `days` und `equipment`: nur bekannte Werte übernehmen, ohne Doppelte, **sortiert in der Reihenfolge von `DAYS` bzw. `EQUIPMENT`**; fehlt der Schlüssel → leere Liste.
- `duplicate_profile()` (nutzt `from_dict(to_dict())`) liefert damit unabhängige Kopien der Listen.
- Bestehende Felder und Tests bleiben unverändert.

## Tests
`tests/test_spar_profile.gd` anhängen:
- `test_merkmale_standard`: `SparProfile.new()` → `weight_class` -1, `weight_name()` „keine Angabe“, `days` und `equipment` leer
- `test_merkmale_speichern_laden`: Profil mit `weight_class = 2`, `days = ["Sa", "Mo"]`, `equipment = ["Matte"]` → `SparProfile.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))` hat `weight_class` 2 (`typeof` ist `TYPE_INT`), `days` `["Mo", "Sa"]`, `equipment` `["Matte"]`, `weight_name()` „Schwer (über 84 kg)“
- `test_alte_daten`: `from_dict({"id": "p09", "name": "Test", "art": "Boxen", "level": 0, "years": 1, "age": 20, "bio": ""})` → `weight_class` -1, `days` leer, `equipment` leer
- `test_unbekannte_werte`: `from_dict` mit `weight_class` 7, `days` `["Mo", "Montag", "Mo"]`, `equipment` `["Helm", "Pratzen"]` → -1, `["Mo"]`, `["Pratzen"]`
- `test_kopie_unabhaengig`: `p.days = ["Mo"]`; `var q := p.duplicate_profile()`; `q.days.append("Di")` → `p.days.size()` bleibt 1

Review (18.10.2026): gemergt.
