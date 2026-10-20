---
id: T-0463
title: Eigener „Match!“-Bildschirm (MatchOverlay)
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9): Bei einem gegenseitigen Interesse erscheint ein eigener Bildschirm wie in modernen Dating-Apps: großer Titel „Match!“, beide Porträts nebeneinander, Knöpfe „Nachricht schreiben“ und „Weiter entdecken“. Hier entsteht nur die neue Klasse; der Einbau folgt in T-0464.

## Dateien
- `scripts/match_overlay.gd` – neue Klasse `MatchOverlay`
- `tests/test_match_overlay.gd` – neue Tests

## Akzeptanzkriterien
- `class_name MatchOverlay`, `extends Control`. Alle Elemente im Code (`_init()`), Farben nur aus `UiStyle`.
- `signal write_requested(match_id: String)` und `signal closed`.
- Variablen: `var match_id := ""`, `var title_label: Label` (Text „Match!“, `UiStyle.SIZE_HERO`, Farbe `UiStyle.ACCENT_2`, zentriert), `var text_label: Label`, `var me_avatar: AvatarView`, `var other_avatar: AvatarView` (beide `set_diameter(200.0)`), `var write_button: Button` (`UiStyle.button("Nachricht schreiben", UiStyle.ACCENT)`), `var continue_button: Button` (`UiStyle.button("Weiter entdecken")`).
- Hintergrund: `ColorRect` über die ganze Fläche (`set_anchors_preset(Control.PRESET_FULL_RECT)`) mit `Color(UiStyle.BG, 0.94)`; Inhalt senkrecht mittig in einem `VBoxContainer` mit `UiStyle.GAP` Abstand, die Avatare nebeneinander in einem `HBoxContainer` (zentriert).
- `mouse_filter = Control.MOUSE_FILTER_STOP` (Klicks gehen nicht an die Karte darunter). Anfangs `visible = false`.
- `func show_match(me: SparProfile, other: SparProfile, p_match_id: String) -> void`: setzt `match_id`, beide Avatare, `text_label.text = "Du und %s wollt zusammen trainieren." % other.name`, `visible = true`.
- `write_button` → `visible = false`, dann `write_requested.emit(match_id)`. `continue_button` → `visible = false`, dann `closed.emit()`.

## Tests
`tests/test_match_overlay.gd` (Overlay an `(Engine.get_main_loop() as SceneTree).root` hängen, in `teardown()` mit `free()` freigeben). Für Signale einen Zähler als Klasse verwenden (`class _Counter extends RefCounted: var count := 0; var last := ""`), keine einfachen Variablen in Lambdas, die ändern sich in GDScript nicht nach außen.
- `test_anfangs_versteckt`: `visible` falsch, `title_label.text` „Match!“.
- `test_zeigen`: `show_match(DemoData.profiles()[0], DemoData.profiles()[1], "m7")` → `visible` wahr, `match_id` „m7“, `text_label.text` enthält den Namen von `DemoData.profiles()[1]`, `other_avatar.profile.id` „p02“, `me_avatar.profile.id` „p01“.
- `test_schreiben`: nach `show_match(...)` `write_button.pressed.emit()` → Zähler für `write_requested` 1, übergebene ID „m7“, `visible` falsch.
- `test_weiter`: nach `show_match(...)` `continue_button.pressed.emit()` → Zähler für `closed` 1, `visible` falsch.

Review (20.10.2026): gemergt, nachgebessert: Knöpfe waren anfangs versteckt und blendeten nur sich selbst aus, Hintergrundfarbe und Zentrierung nach Ticket, liegengelassene Hilfsdateien (scripts/run_tests.gd, simple_test.gd, test_fix.gd, run_test_match_overlay.tscn) entfernt, Sichtbarkeit in den Tests geprüft.
