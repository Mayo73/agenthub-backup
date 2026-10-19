---
id: T-0354
title: ProfileCard zeigt Gewicht, Verfügbarkeit und Ausrüstung
project: sparring
priority: 3
after: T-0330, T-0352, T-0353
---
## Ziel
Meilenstein „Profilmerkmale“: Die Karte einer Testperson unter „Entdecken“ zeigt zusätzlich die neuen Merkmale.

## Dateien
- `scripts/profile_card.gd` – neues Label
- `tests/test_profile_card.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Variable `var facts_label: Label`, angelegt mit `UiStyle.label("", UiStyle.SIZE_SMALL, UiStyle.MUTED)`, direkt **nach** `bio_label` in derselben `VBoxContainer`.
- `set_profile(p)` setzt zusätzlich `facts_label.text = ProfileFacts.all_text(p)`.
- Alles Übrige bleibt unverändert; die bestehenden Tests bleiben grün.

## Tests
`tests/test_profile_card.gd` anhängen (gleiches `setup()`/`teardown()`):
- `test_merkmale_sam`: mit `DemoData.profiles()[1]` → `facts_label.text` gleich „Gewicht: Schwer (über 84 kg)\nVerfügbar: Mo, Mi, Fr\nAusrüstung: Handschuhe, Schienbeinschoner, Mundschutz“
- `test_merkmale_jonas`: mit `DemoData.profiles()[3]` → `facts_label.text` endet mit „Ausrüstung: keine eigene“
- `test_merkmale_reihenfolge`: `facts_label.get_index()` ist größer als `bio_label.get_index()`

Review (18.10.2026): gemergt.
