---
id: T-0330
title: ProfileCard – Karte einer Testperson
project: sparring
priority: 3
after: T-0322, T-0328
---
## Ziel
Meilenstein „Swipe und Match“: Eine Karte zeigt eine Testperson mit Avatar, Name, Alter, Kampfsportart, Erfahrung und Kurztext. Sie trägt sichtbar den Hinweis „Testprofil“ (Abnahmekriterium 1).

## Dateien
- `scripts/profile_card.gd` – neu, Klasse `ProfileCard`
- `tests/test_profile_card.gd` – neu

## Akzeptanzkriterien
`class_name ProfileCard`, `extends PanelContainer`:
- In `_init()` Hintergrund `add_theme_stylebox_override("panel", UiStyle.panel(UiStyle.CARD, 24))` und die Kinder im Code anlegen: eine `VBoxContainer` mit
  - `var demo_tag: Label` – Text `"TESTPROFIL · fiktiv"`, `UiStyle.SIZE_SMALL`, Farbe `UiStyle.DEMO`
  - `var avatar: AvatarView` – Durchmesser 220, waagerecht zentriert (`size_flags_horizontal = Control.SIZE_SHRINK_CENTER`)
  - `var name_label: Label` – `UiStyle.SIZE_TITLE`, zentriert
  - `var art_label: Label` – zentriert, Farbe `UiStyle.ACCENT`
  - `var level_label: Label` – zentriert, Farbe `UiStyle.MUTED`
  - `var bio_label: Label` – `UiStyle.SIZE_NORMAL`
- `var profile: SparProfile = null`
- `func set_profile(p: SparProfile) -> void`: füllt die Texte:
  - `name_label.text = "%s, %d" % [p.name, p.age]`
  - `art_label.text = p.art`
  - `level_label.text = "%s · %d Jahre Training" % [p.level_name(), p.years]` (bei `years == 1`: „1 Jahr Training“)
  - `bio_label.text = p.bio`
  - `avatar.set_profile(p)`
- Alle Labels über `UiStyle.label()` anlegen.

## Tests
`tests/test_profile_card.gd`: Karte in `setup()` erzeugen und an `(Engine.get_main_loop() as SceneTree).root` hängen, in `teardown()` `free()`.
- `test_testprofil_hinweis`: `demo_tag.text` enthält „TESTPROFIL“
- `test_texte`: mit `DemoData.profiles()[1]` (Sam) → `name_label.text` „Sam, 33“, `art_label.text` „MMA“, `level_label.text` „Erfahren · 7 Jahre Training“, `bio_label.text` gleich `bio`
- `test_ein_jahr`: mit `DemoData.profiles()[3]` (Jonas, 1 Jahr) → `level_label.text` „Einsteiger · 1 Jahr Training“
- `test_avatar`: `avatar.profile` ist das gesetzte Profil

Review (18.10.2026): gemergt.
