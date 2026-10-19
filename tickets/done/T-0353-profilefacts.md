---
id: T-0353
title: ProfileFacts – Texte zu Gewicht, Tagen, Ausrüstung und gemeinsamen Tagen
project: sparring
priority: 3
after: T-0351
---
## Ziel
Meilenstein „Profilmerkmale“: Eine kleine Logik-Klasse erzeugt die deutschen Anzeigetexte zu den neuen Profilmerkmalen und findet gemeinsame Trainingstage zweier Personen (für Karte, Profil und Treffen).

## Dateien
- `scripts/profile_facts.gd` – neu, Klasse `ProfileFacts`
- `tests/test_profile_facts.gd` – neu

## Akzeptanzkriterien
`class_name ProfileFacts`, `extends RefCounted`, nur statische Funktionen:
- `static func weight_text(p: SparProfile) -> String`: `"Gewicht: " + p.weight_name()`
- `static func days_text(p: SparProfile) -> String`: `"Verfügbar: Di, Do, Sa"` (Tage mit „, “ verbunden); ohne Tage `"Verfügbar: nach Absprache"`; alle sieben Tage `"Verfügbar: täglich"`
- `static func equipment_text(p: SparProfile) -> String`: `"Ausrüstung: Mundschutz, Matte"`; ohne Ausrüstung `"Ausrüstung: keine eigene"`
- `static func all_text(p: SparProfile) -> String`: die drei Texte oben mit `"\n"` verbunden (Reihenfolge Gewicht, Verfügbar, Ausrüstung)
- `static func common_days(a: SparProfile, b: SparProfile) -> Array[String]`: Tage, die beide haben, in der Reihenfolge von `SparProfile.DAYS`
- `static func common_days_text(a: SparProfile, b: SparProfile) -> String`: `"Gemeinsame Tage: Di, Sa"`; ohne gemeinsame Tage `"Keine gemeinsamen Tage – sprecht euch ab."`

## Tests
`tests/test_profile_facts.gd`: Profile im Test selbst bauen (`SparProfile.new()`, Felder setzen), nicht aus `DemoData`.
- `test_gewicht`: `weight_class = 0` → „Gewicht: Leicht (bis 66 kg)“; -1 → „Gewicht: keine Angabe“
- `test_tage`: `days = ["Di", "Do", "Sa"]` → „Verfügbar: Di, Do, Sa“; leer → „Verfügbar: nach Absprache“; alle sieben → „Verfügbar: täglich“
- `test_ausruestung`: `["Mundschutz", "Matte"]` → „Ausrüstung: Mundschutz, Matte“; leer → „Ausrüstung: keine eigene“
- `test_alles`: `weight_class = 1`, `days = ["Mo"]`, `equipment = []` → „Gewicht: Mittel (66–84 kg)\nVerfügbar: Mo\nAusrüstung: keine eigene“
- `test_gemeinsame_tage`: a `["Mo", "Mi", "Sa"]`, b `["Mi", "Sa", "So"]` → `["Mi", "Sa"]`, Text „Gemeinsame Tage: Mi, Sa“
- `test_keine_gemeinsamen_tage`: a `["Mo"]`, b `["Di"]` → leer, Text „Keine gemeinsamen Tage – sprecht euch ab.“

Review (18.10.2026): gemergt.
