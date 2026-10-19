---
id: T-0362
title: Spieltest „profil“ – Profil bearbeiten, Neustart, Name bleibt
project: sparring
priority: 3
after: T-0336, T-0356
---
## Ziel
Meilenstein „Abnahme“ (Abnahmekriterium 2, dazu die Profilmerkmale): Ein Spieltest ändert im Profil-Reiter Name, Alter und einen Trainingstag, startet die App neu und prüft, dass alles erhalten ist. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/profil.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"` (in `_init()`), `describe()` liefert `"Profil bearbeiten und nach Neustart wiederfinden"`. Vorlage: `playtests/start.gd`.
- Eigene Datei `const STORE := "user://spieltest_profil.json"`: zu Beginn von `run()` löschen, falls vorhanden, dann `scene.use_store(STORE)`; am Ende löschen. Nie `user://sparring.json` anfassen.
- Ablauf, zwischen den Schritten `await wait(0.3)`:
  1. `scene.tab_buttons["profil"].pressed.emit()`; `var ps := scene.screen as ProfileScreen`; `check(ps != null, "Profil-Reiter zeigt das Profil")`
  2. `ps.name_edit.text = "Alexa"`, `ps.age_spin.value = 30`, `ps.day_boxes["So"].button_pressed = true`, `ps.save_button.pressed.emit()` → `check(ps.error_label.text == "Gespeichert.", "Profil gespeichert")`; `shot("profil")`
  3. `check(scene.perspective.picker.get_item_text(0).begins_with("Du bist: Alexa"), "Name in der Demo-Leiste aktualisiert")`
  4. Neustart: `await reload_scene()`, danach `scene.use_store(STORE)` → `check(scene.state.profile("p01").name == "Alexa", "Name nach Neustart erhalten")`, `check(scene.state.profile("p01").age == 30, "Alter nach Neustart erhalten")`, `check(scene.state.profile("p01").days.has("So"), "Trainingstag nach Neustart erhalten")`
  5. Profil-Reiter erneut öffnen → `check((scene.screen as ProfileScreen).name_edit.text == "Alexa", "Feld zeigt den gespeicherten Namen")`; `shot("profil_neustart")`
- Keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test profil`).

Review (19.10.2026): gemergt.
