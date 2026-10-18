---
id: T-0337
title: SparFilter – Testprofile nach Kampfsportart und Erfahrung filtern
project: sparring
priority: 3
after: T-0327
---
## Ziel
Meilenstein „Swipe und Match“ (Lastenheft „Soll“: „Kampfsportart und Erfahrung als einfache Filter für die vorhandenen Testprofile“). Logik-Klasse plus Einbau in `AppState.candidates()`. Der Filter schränkt nur ein, was angezeigt wird; er verhindert keine Matches zwischen Sportarten (Kriterium 4).

## Dateien
- `scripts/spar_filter.gd` – neu, Klasse `SparFilter`
- `scripts/app_state.gd` – Filter einbauen
- `tests/test_spar_filter.gd` – neu
- `tests/test_app_state.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- `class_name SparFilter`, `extends RefCounted`:
  - `var art := ""` – leer = alle Sportarten
  - `var level := -1` – -1 = jede Erfahrung, sonst genau diese Stufe 0–2
  - `func matches(p: SparProfile) -> bool`
  - `func apply(profiles: Array[SparProfile]) -> Array[SparProfile]`: die passenden in gleicher Reihenfolge
  - `func is_active() -> bool`: `art != ""` oder `level != -1`
  - `func clear() -> void`
  - `func describe() -> String`: `"Alle Testprofile"` ohne Filter; sonst die gesetzten Teile mit „ · “ verbunden, z. B. `"MMA · Erfahren"`, `"Boxen"`, `"Einsteiger"` (Stufenname aus `SparProfile.LEVELS`)
  - `func to_dict() -> Dictionary` (`art`, `level`) und `static func from_dict(d: Dictionary) -> SparFilter` (`level` als `int`, fehlend → Standard)
- `scripts/app_state.gd`:
  - `var filter := SparFilter.new()`
  - `candidates()` wendet zusätzlich `filter.apply(...)` an
  - `to_dict()` bekommt den Schlüssel `filter`; `from_dict()` liest ihn (fehlt er, leerer Filter)

## Tests
- `tests/test_spar_filter.gd` mit `all = DemoData.profiles()`:
  - `test_ohne_filter`: `apply(all).size()` 8, `is_active()` falsch, `describe()` „Alle Testprofile“
  - `test_sportart`: `art = "Boxen"` → IDs `["p03", "p08"]`, `describe()` „Boxen“
  - `test_erfahrung`: `level = 2` → IDs `["p02", "p05", "p08"]`
  - `test_beides`: `art = "Jiu-Jitsu"`, `level = 2` → `["p05"]`, `describe()` „Jiu-Jitsu · Erfahren“
  - `test_zuruecksetzen`: Filter setzen, `clear()` → `is_active()` falsch
  - `test_speichern_laden`: `art = "MMA"`, `level = 1` → `from_dict(to_dict())` gleich, `typeof(level)` ist `TYPE_INT`
- `tests/test_app_state.gd` anhängen:
  - `test_filter_kandidaten`: als p01 `state.filter.art = "Boxen"` → `candidates()` IDs `["p03", "p08"]`
  - `test_filter_kein_matchverbot`: Filter `art = "Boxen"`; als p02 `like("p01")`, als p01 `like("p02")` → ergibt „m1“ (Filter betrifft nur die Anzeige)
  - `test_filter_gespeichert`: `filter.level = 0` → `AppState.from_dict(state.to_dict()).filter.level` 0
