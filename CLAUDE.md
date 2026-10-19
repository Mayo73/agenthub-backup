# Sparring – Regeln für Agents

Android-Prototyp in Godot 4.7 mit GDScript: Kampfsportpartner finden sich über gegenseitige Swipe-Matches, schreiben sich im Demochat und vereinbaren ein freiwilliges Training draußen. **Alles sind fiktive, lokale Testdaten**: kein Konto, kein Server, kein Netzwerk, keine Standortabfrage. Die Oberfläche ist deutsch, Hochformat 720 × 1280.

## Architektur (wichtig)

- Logik gehört in testbare Klassen (`extends RefCounted`) ohne Nodes. Bildschirme (`extends Control`) zeigen nur an und melden Klicks.
- Alle Bedienelemente entstehen **im Code** (`Button.new()`, `add_child(...)`), nicht in `.tscn`-Dateien. Die einzige Szene ist `scenes/main.tscn` mit `Main`.
- Aussehen nur über `UiStyle` (Farben, Schriftgrößen, `UiStyle.label()`, `UiStyle.button()`, `UiStyle.panel()`), keine eigenen Farbwerte in Bildschirmen.
- Jeder Knopf, den ein Test drückt, ist als Variable erreichbar; Tests lösen ihn mit `button.pressed.emit()` aus.
- Bildschirme ändern den Zustand nicht selbst, sondern über `AppState`, und senden danach das Signal `changed`. `Main` speichert dann mit `StateStore.save()`.
- **Perspektivwechsel:** Jede der acht Testpersonen kann die „aktive“ Person sein (`AppState.active_id`). So lassen sich beide Seiten eines Matches durchspielen. Das ist eine Demofunktion und wird immer als solche beschriftet (Farbe `UiStyle.DEMO`).
- Neue Klassen bekommen ein `class_name`.

## Datenmodell

- `SparProfile`: `id` („p01“ … „p08“), `name`, `art` (Kampfsportart), `level` (0 Einsteiger, 1 Fortgeschritten, 2 Erfahren), `years`, `age` (mindestens 18), `bio`, `color` (Avatarfarbe). `to_dict()`, `SparProfile.from_dict()`.
- `MatchBook`: Interessen (`like`), Überspringen (`pass_on`), Matches als Dictionary `{"id": "m1", "a": "p01", "b": "p02", "ended_by": ""}`, Blockieren.
- `ChatLog`: Nachrichten `{"match_id": "m1", "from": "p01", "text": "…", "n": 1}`.
- `MeetingBook`: je Match ein Treffvorschlag `{"place", "date", "time", "form", "intensity", "rules", "approved": [ids], "cancelled_by": ""}`. Jede Änderung setzt die Zustimmung zurück.
- `AppState`: hält alles und die aktive Person, `AppState.demo()` liefert den Ausgangszustand.
- `StateStore`: speichert `AppState` als JSON unter `user://sparring.json`.

## Dateien

| Datei | Aufgabe |
|---|---|
| `scripts/main.gd` | `Main`: Kopfzeile `banner` (Prototyp-Hinweis), Inhaltsbereich `content` mit dem aktuellen Bildschirm `screen`, Reiterleiste `tab_bar`/`tab_buttons`; `show_screen(name)` für „entdecken“, „matches“, „profil“ |
| `scripts/ui_style.gd` | `UiStyle`: Farben, Schriftgrößen, Bausteine |

Geplante Klassen (entstehen durch Tickets, Namen genau so verwenden): `SparProfile`, `DemoData`, `MatchBook`, `ChatLog`, `MeetingBook`, `AppState`, `StateStore`, `AvatarView`, `SwipeGesture`, `ProfileCard`, `DiscoverScreen`, `PerspectiveBar`, `MatchesScreen`, `ChatScreen`, `MeetingScreen`, `ProfileScreen`, `ConfirmDialog`, `PlaceSketch`.

## Regeln

- GDScript 4 mit statischen Typen (`var x: int`, `func f() -> void`).
- Einrückung **nur mit Tabs**, niemals mit Leerzeichen.
- Kommentare beginnen mit `#` oder `##`. Es gibt keine Block-Kommentare mit `"""`.
- Zu jeder neuen Logik gehört ein Test in `tests/test_<thema>.gd`:

  ```gdscript
  extends "res://tests/base_test.gd"

  var book: MatchBook

  func setup() -> void:          # optional, läuft vor jedem Test
  	book = MatchBook.new()

  func test_beschreibung() -> void:
  	check_eq(ist_wert, soll_wert, "was geprüft wird")
  	check(bedingung, "was geprüft wird")
  ```
- Tests für Bildschirme hängen den Bildschirm an `(Engine.get_main_loop() as SceneTree).root` und geben ihn in `teardown()` mit `free()` frei (Vorlage: `tests/test_main.gd`).
- Tests, die speichern, nutzen eigene Dateien `user://test_<thema>.json` und löschen sie in `teardown()` mit `DirAccess.remove_absolute(...)`. Nie `user://sparring.json` anfassen.
- Bestehende Tests nicht löschen, umbenennen oder abschwächen.
- Nicht ändern: `verify.cmd`, `tests/run_tests.gd`, `tests/base_test.gd`, `playtests/playtest.gd`.
- Keine Netzwerkzugriffe (`HTTPRequest`), keine Plugins, keine externen Bilder. Avatare zeichnet `AvatarView` selbst.

## Prüfen

`verify.cmd` lädt alle Skripte, startet `scenes/main.tscn` kurz und führt alle `test_*`-Methoden aus. Bestanden nur bei `ERGEBNIS: <n> ok, 0 fehlgeschlagen`.

Spieltests in `playtests/` führt der Hub aus (`hub\tools\spieltest.ps1 -Projekt sparring`), nicht `verify.cmd`.

## Android

Mindestversion Android 7.0 (API 24, Godot-Standard), Renderer „Compatibility“, Hochformat. Export: Vorlage „Android“ in `export_presets.cfg` (arm64-v8a und x86_64, ohne Gradle, signiert mit dem Debug-Schlüssel, keine Internet-Berechtigung, ohne `tests/` und `playtests/`). Bauen macht Claude: `godot --headless --path . --export-debug Android build/sparring.apk` (Ordner `build/` ist ignoriert). Im Emulator `Sparring_Pixel` nur mit `-gpu host` starten; mit der Software-Grafik (SwiftShader, Standard bei `-no-window`) bleibt der Bildschirm leer. Icon: `assets/icon/icon.png` (selbst gezeichnet).
