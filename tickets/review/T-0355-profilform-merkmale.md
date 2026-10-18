---
id: T-0355
title: ProfileForm – Merkmale prüfen und übernehmen
project: sparring
priority: 3
after: T-0334, T-0351
---
## Ziel
Meilenstein „Profilmerkmale“: Das eigene Demoprofil soll auch Gewichtsklasse, Trainingstage und Ausrüstung bearbeiten können. `ProfileForm` prüft und übernimmt diese Werte.

## Dateien
- `scripts/profile_form.gd` – `errors`, `values_of`, `applied` erweitern
- `tests/test_profile_form.gd` – Tests anhängen

## Akzeptanzkriterien
- `values_of(p)` liefert zusätzlich `weight_class` (int), `days` (Kopie von `p.days`), `equipment` (Kopie von `p.equipment`).
- `errors(values)` prüft **nach** den bisherigen Prüfungen zusätzlich. Fehlende Schlüssel sind hier gültig, damit `errors({})` weiterhin genau 5 Einträge hat:
  - `weight_class` vorhanden und nicht zwischen -1 und 2 → `"Gewichtsklasse ist ungültig"`
  - `days` enthält einen Wert, der nicht in `SparProfile.DAYS` steht → `"Unbekannter Trainingstag"`
  - `equipment` enthält einen Wert, der nicht in `SparProfile.EQUIPMENT` steht → `"Unbekannte Ausrüstung"`
- `applied(p, values)`: übernimmt zusätzlich `weight_class`, `days`, `equipment`, wenn die Schlüssel vorhanden sind (sonst bleiben die Werte des Originals). `days` und `equipment` ohne Doppelte und in der Reihenfolge von `SparProfile.DAYS` bzw. `SparProfile.EQUIPMENT`. Das Original bleibt unverändert.
- Bestehende Tests bleiben grün.

## Tests
`tests/test_profile_form.gd` anhängen (gleiches `setup()`):
- `test_merkmale_in_werten`: `ok` hat die Schlüssel `weight_class`, `days`, `equipment`; `errors(ok)` bleibt `[]`
- `test_merkmale_uebernehmen`: `ok` mit `weight_class` 2, `days` `["Sa", "Mo", "Sa"]`, `equipment` `["Pratzen", "Handschuhe"]` → `applied(p, ok)` hat `weight_class` 2, `days` `["Mo", "Sa"]`, `equipment` `["Handschuhe", "Pratzen"]`; `p.weight_class` unverändert
- `test_gewicht_ungueltig`: `ok` mit `weight_class` 5 → `errors(ok)` gleich `["Gewichtsklasse ist ungültig"]`
- `test_unbekannter_tag`: `ok` mit `days` `["Montag"]` → `["Unbekannter Trainingstag"]`
- `test_unbekannte_ausruestung`: `ok` mit `equipment` `["Helm"]` → `["Unbekannte Ausrüstung"]`
- `test_leer_weiter_fuenf`: `errors({}).size()` ist 5
