---
id: T-0332
title: Perspektivwechsel und „Entdecken“ in der App, Zustand wird gespeichert
project: sparring
priority: 3
after: T-0367, T-0331
---
## Ziel
Meilenstein „Swipe und Match“: Die App lädt beim Start den gespeicherten Zustand, zeigt oben eine deutlich als Demo gekennzeichnete Leiste „Du bist: Alex ▾“ zum Wechseln der Testperson und im Reiter „Entdecken“ den echten Bildschirm. Nach jeder Änderung wird gespeichert (Abnahmekriterien 2, 3, 9).

## Dateien
- `scripts/perspective_bar.gd` – neu, Klasse `PerspectiveBar`
- `scripts/main.gd` – Einbau
- `tests/test_perspective_bar.gd` – neu
- `tests/test_main.gd` – Tests anhängen (bestehende nicht ändern)

## Akzeptanzkriterien
- `scripts/perspective_bar.gd`: `class_name PerspectiveBar`, `extends PanelContainer`:
  - `signal switched(id: String)`
  - Hintergrund `UiStyle.panel(UiStyle.CARD, 0)`; darin eine `HBoxContainer` mit `var tag_label: Label` (Text `"DEMO-PERSPEKTIVE"`, `UiStyle.SIZE_SMALL`, Farbe `UiStyle.DEMO`), `var avatar: AvatarView` (Durchmesser 56) und `var picker: OptionButton` (`SIZE_EXPAND_FILL`, Schriftgröße `UiStyle.SIZE_NORMAL`, Mindesthöhe `UiStyle.BUTTON_HEIGHT`)
  - `func set_state(state: AppState) -> void`: füllt `picker` mit einem Eintrag je Profil, Text `"Du bist: %s (%s)" % [name, art]`, Metadaten = Profil-ID (`set_item_metadata`); wählt die aktive Person aus; `avatar.set_profile(state.active())`
  - `picker.item_selected` → `switched.emit(<ID des Eintrags>)`
- `scripts/main.gd`:
  - neue Variablen `var state: AppState`, `var store_path := StateStore.DEFAULT_PATH`, `var perspective: PerspectiveBar`
  - in `_ready()` **vor** dem Aufbau: `state = StateStore.load_state(store_path)`; `perspective` direkt unter der Kopfzeile in `layout` einfügen, `perspective.set_state(state)`, `perspective.switched` → `_on_switched`
  - `func _on_switched(id: String) -> void`: `state.switch_to(id)`, `save()`, `perspective.set_state(state)`, aktuellen Bildschirm neu aufbauen (`show_screen(current_screen)`)
  - `func save() -> void`: `StateStore.save(state, store_path)`
  - `_make_screen("entdecken")` liefert `DiscoverScreen.new(state)` und verbindet dessen `changed` mit `save`; die anderen Bildschirme bleiben Platzhalter
  - `func use_store(path: String) -> void` für Tests: `store_path = path`, `state = StateStore.load_state(path)`, `perspective.set_state(state)`, `show_screen(current_screen)`
- Die bestehenden Tests in `tests/test_main.gd` bleiben unverändert grün.

## Tests
- `tests/test_perspective_bar.gd` (Leiste in `setup()` an die Wurzel hängen, `teardown()` `free()`):
  - `test_eintraege`: nach `set_state(AppState.demo())` hat `picker` 8 Einträge, Eintrag 0 „Du bist: Alex (Jiu-Jitsu)“, ausgewählt 0, `tag_label.text` enthält „DEMO“
  - `test_wechsel_signal`: Zähler/ID über `switched` merken, `picker.select(1)` und `picker.item_selected.emit(1)` → ID „p02“
- `tests/test_main.gd` anhängen (Testdatei `const TEST_PATH := "user://test_main.json"`; in jedem neuen Test zuerst `main.use_store(TEST_PATH)`; am Ende des Tests `DirAccess.remove_absolute(TEST_PATH)`):
  - `test_entdecken_ist_echt`: `main.screen is DiscoverScreen`
  - `test_wechsel_speichert`: `main._on_switched("p02")` → `main.state.active_id` „p02“; `StateStore.load_state(TEST_PATH).active_id` „p02“; `main.screen is DiscoverScreen`
  - `test_interesse_wird_gespeichert`: `(main.screen as DiscoverScreen).like_button.pressed.emit()` → `StateStore.load_state(TEST_PATH).book.likes` enthält `"p01>p02"`

Review (18.10.2026): selbst umgesetzt (alle Agent-Versuche scheiterten an Ollama, Grafikspeicher voll), verify grün.
Nachgebessert: Dabei die Initialen im AvatarView mittig gesetzt (standen oberhalb des Kreises) und die Demo-Leiste auf Bildschirmbreite begrenzt.
