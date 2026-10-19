---
id: T-0334
title: ProfileForm – Eingaben fürs eigene Profil prüfen und übernehmen
project: sparring
priority: 3
after: T-0322
---
## Ziel
Meilenstein „Demodaten und Profil“: Das eigene Demoprofil lässt sich bearbeiten (Lastenheft „Profile“, Abnahmekriterium 2). Die Prüfung der Eingaben steckt in einer testbaren Logik-Klasse; der Bildschirm (T-0335) zeigt nur an.

## Dateien
- `scripts/profile_form.gd` – neu, Klasse `ProfileForm`
- `tests/test_profile_form.gd` – neu

## Akzeptanzkriterien
`class_name ProfileForm`, `extends RefCounted`:
- `const NAME_MAX := 30`, `const BIO_MAX := 120`, `const AGE_MIN := 18`, `const AGE_MAX := 99`, `const YEARS_MAX := 60`
- `static func errors(values: Dictionary) -> Array[String]`: `values` hat die Schlüssel `name` (String), `art` (String), `level` (int), `years` (int), `age` (int), `bio` (String). Liefert die Probleme auf Deutsch in dieser Reihenfolge:
  - `name` nach `strip_edges()` leer → `"Name fehlt"`
  - `name` länger als `NAME_MAX` → `"Name ist zu lang (höchstens 30 Zeichen)"`
  - `art` nicht in `DemoData.ARTS` → `"Kampfsportart fehlt"`
  - `level` nicht 0–2 → `"Erfahrung fehlt"`
  - `age` kleiner `AGE_MIN` → `"Nur Erwachsene: Alter mindestens 18"`
  - `age` größer `AGE_MAX` → `"Alter ist ungültig"`
  - `years` kleiner 0 oder größer `YEARS_MAX` → `"Trainingsjahre sind ungültig"`
  - `bio` nach `strip_edges()` länger als `BIO_MAX` → `"Text ist zu lang (höchstens 120 Zeichen)"`
  Fehlende Schlüssel zählen als leer bzw. -1 (also fehlend).
- `static func values_of(p: SparProfile) -> Dictionary`: die sechs Werte des Profils.
- `static func applied(p: SparProfile, values: Dictionary) -> SparProfile`: Ist `errors(values)` nicht leer, `null`. Sonst eine **Kopie** (`p.duplicate_profile()`) mit den neuen Werten (Texte mit `strip_edges()`); `id` und `color` bleiben wie im Original, das Original bleibt unverändert.

## Tests
`tests/test_profile_form.gd`, in `setup()` `p = DemoData.profiles()[0]` (Alex) und `ok = ProfileForm.values_of(p)`:
- `test_gueltig`: `errors(ok)` ist `[]`
- `test_name_fehlt`: `ok` mit `name` „   “ → `["Name fehlt"]`
- `test_name_zu_lang`: Name aus 31 „a“ → enthält „Name ist zu lang (höchstens 30 Zeichen)“
- `test_minderjaehrig`: `age` 17 → genau `["Nur Erwachsene: Alter mindestens 18"]`
- `test_unbekannte_sportart`: `art` „Schach“ → `["Kampfsportart fehlt"]`
- `test_leer`: `errors({})` hat 5 Einträge: „Name fehlt“, „Kampfsportart fehlt“, „Erfahrung fehlt“, „Nur Erwachsene: Alter mindestens 18“, „Trainingsjahre sind ungültig“
- `test_bio_zu_lang`: `bio` aus 121 „x“ → `["Text ist zu lang (höchstens 120 Zeichen)"]`
- `test_uebernehmen`: `ok` mit `name` „ Alexa “ und `level` 2 → `applied(p, ok)` hat `name` „Alexa“, `level` 2, `id` „p01“; `p.name` bleibt „Alex“
- `test_fehler_ohne_aenderung`: `applied(p, {"name": ""})` ist `null`; `p.name` bleibt „Alex“

Review (18.10.2026): gemergt.
