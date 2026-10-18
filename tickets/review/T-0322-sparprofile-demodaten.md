---
id: T-0322
title: Testprofile – SparProfile und DemoData
project: sparring
priority: 3
---
## Ziel
Meilenstein „Demodaten und Profil“: Die App braucht ein Profil-Objekt und acht fiktive, erwachsene Testpersonen. Darunter müssen Jiu-Jitsu, MMA und Boxen sein (Abnahmekriterium 1).

## Dateien
- `scripts/spar_profile.gd` – neu, Klasse `SparProfile`
- `scripts/demo_data.gd` – neu, Klasse `DemoData`
- `tests/test_spar_profile.gd` – neu
- `tests/test_demo_data.gd` – neu

## Akzeptanzkriterien
- `scripts/spar_profile.gd`: `class_name SparProfile`, `extends RefCounted`, mit
  - `const LEVELS: Array[String] = ["Einsteiger", "Fortgeschritten", "Erfahren"]`
  - Variablen `var id := ""`, `var name := ""`, `var art := ""`, `var level := 0`, `var years := 0`, `var age := 18`, `var bio := ""`, `var color := Color(0.5, 0.5, 0.5)`
  - `func level_name() -> String`: `LEVELS[clampi(level, 0, 2)]`
  - `func initials() -> String`: erster Buchstabe jedes Worts von `name`, groß, höchstens 2 Buchstaben („Alex Berger“ → „AB“, „Mo“ → „M“, leer → „?“)
  - `func to_dict() -> Dictionary`: Schlüssel `id`, `name`, `art`, `level`, `years`, `age`, `bio`, `color` (Farbe als Hex-Text `color.to_html(false)`)
  - `static func from_dict(d: Dictionary) -> SparProfile`: Gegenstück, fehlende Schlüssel ergeben die Standardwerte; `level`, `years`, `age` als `int`; `color` mit `Color.html(...)`
  - `func duplicate_profile() -> SparProfile`: `from_dict(to_dict())`
- `scripts/demo_data.gd`: `class_name DemoData`, `extends RefCounted`, mit
  - `const ARTS: Array[String] = ["Jiu-Jitsu", "MMA", "Boxen", "Kickboxen", "Muay Thai", "Ringen", "Judo"]`
  - `static func profiles() -> Array[SparProfile]`: genau 8 neue Profile mit den IDs `"p01"` bis `"p08"` in dieser Reihenfolge. Werte genau so:

| id | name | art | level | years | age | color |
|---|---|---|---|---|---|---|
| p01 | Alex | Jiu-Jitsu | 1 | 4 | 29 | `Color(0.20, 0.55, 0.85)` |
| p02 | Sam | MMA | 2 | 7 | 33 | `Color(0.85, 0.35, 0.25)` |
| p03 | Mira | Boxen | 1 | 3 | 26 | `Color(0.75, 0.30, 0.65)` |
| p04 | Jonas | Kickboxen | 0 | 1 | 22 | `Color(0.30, 0.70, 0.40)` |
| p05 | Lea | Jiu-Jitsu | 2 | 9 | 35 | `Color(0.90, 0.65, 0.20)` |
| p06 | Deniz | Muay Thai | 1 | 5 | 30 | `Color(0.25, 0.65, 0.70)` |
| p07 | Kim | Ringen | 0 | 2 | 24 | `Color(0.55, 0.45, 0.85)` |
| p08 | Tarek | Boxen | 2 | 11 | 38 | `Color(0.60, 0.60, 0.30)` |

  - `bio` je Profil ein kurzer, freundlicher deutscher Satz über Training draußen (frei formulieren, nicht leer, höchstens 120 Zeichen, keine echten Orte oder Vereine).
  - `static func profile_ids() -> Array[String]`: die 8 IDs in Reihenfolge.

## Tests
- `tests/test_spar_profile.gd`:
  - `test_initialen`: „Alex Berger“ → „AB“; „Mo“ → „M“; „“ → „?“; „anna maria lang“ → „AM“
  - `test_stufe`: `level = 2` → `level_name()` ist „Erfahren“; `level = 7` → „Erfahren“
  - `test_hin_und_zurueck`: Profil mit allen Feldern (z. B. id „x1“, name „Test“, art „MMA“, level 1, years 3, age 40, bio „Hallo“, color `Color(1, 0, 0)`) → `from_dict(to_dict())` hat dieselben Werte (Farbe: `is_equal_approx`)
  - `test_fehlende_schluessel`: `from_dict({"id": "x"})` hat `age` 18, `name` „“, `level` 0
- `tests/test_demo_data.gd`:
  - `test_acht_profile`: 8 Profile, IDs `p01`…`p08`, alle IDs verschieden
  - `test_pflicht_sportarten`: unter den `art`-Werten sind „Jiu-Jitsu“, „MMA“ und „Boxen“
  - `test_erwachsen_und_vollstaendig`: jedes Profil hat `age >= 18`, nicht leeren `name` und `bio`, `art` in `DemoData.ARTS`, `level` 0–2
  - `test_frische_kopien`: zweimal `profiles()` aufrufen, Namen im ersten Ergebnis ändern → zweites Ergebnis unverändert
