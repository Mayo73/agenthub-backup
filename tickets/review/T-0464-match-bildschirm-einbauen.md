---
id: T-0464
title: „Match!“-Bildschirm im Entdecken-Bildschirm zeigen, „Nachricht schreiben“ öffnet den Chat
project: sparring
priority: 2
after: T-0462, T-0463
---
## Ziel
Auftrag „Modernes Design“ (M9): Entsteht beim Interesse ein Match, legt sich der `MatchOverlay` aus T-0463 über den Entdecken-Bildschirm. „Nachricht schreiben“ öffnet direkt den Chat zu diesem Match, „Weiter entdecken“ schließt den Bildschirm.

## Dateien
- `scripts/discover_screen.gd` – Overlay anlegen und zeigen, neues Signal
- `scripts/main.gd` – Signal mit `show_chat` verbinden
- `tests/test_discover_screen.gd`, `tests/test_main.gd` – Tests ergänzen

## Akzeptanzkriterien
- `DiscoverScreen`: `signal open_chat(match_id: String)`; `var match_overlay: MatchOverlay`, in `_init()` als **letztes** Kind des Bildschirms angelegt (nach dem `MarginContainer`), `set_anchors_preset(Control.PRESET_FULL_RECT)`.
- In `decide_like()` bei einem Match (nicht leere ID) zusätzlich `match_overlay.show_match(state.active(), profile, id)`. Das bisherige `match_label` und das Signal `matched` bleiben unverändert.
- `match_overlay.write_requested` wird an `open_chat` weitergegeben (`match_overlay.write_requested.connect(func(mid: String) -> void: open_chat.emit(mid))`).
- `Main._make_screen("entdecken")`: `discover.open_chat.connect(show_chat)`.

## Tests
Für Signale einen Zähler als Klasse verwenden (in `test_discover_screen.gd` gibt es schon `_Counter`), keine einfachen Variablen in Lambdas.
- `tests/test_discover_screen.gd`, `test_match_bildschirm`: wie `test_match_hinweis` (p02 mag p01, dann Perspektive p01, neuer Bildschirm, `like_button.pressed.emit()`) → `new_screen.match_overlay.visible` wahr, `new_screen.match_overlay.text_label.text` enthält „Sam“; `new_screen.match_overlay.write_button.pressed.emit()` → `open_chat` einmal gesendet, `match_overlay.visible` falsch.
- `tests/test_discover_screen.gd`, `test_kein_match_kein_bildschirm`: im Demozustand `like_button.pressed.emit()` → `match_overlay.visible` falsch.
- `tests/test_main.gd`, `test_match_oeffnet_chat`: Hauptszene wie in den anderen Tests der Datei; `main.state.switch_to("p02")`, `main.state.like("p01")`, `main.state.switch_to("p01")`, `main.show_screen("entdecken")`; dann `(main.screen as DiscoverScreen).like_button.pressed.emit()` und `(main.screen as DiscoverScreen).match_overlay.write_button.pressed.emit()` → `main.current_screen` „chat“.
