---
id: T-0504
title: Spieltest „design_voll“ – gefüllter Chat und Treffvorschlag als Material
project: sparring
priority: 2
after: T-0500, T-0501, T-0502, T-0503
---
## Ziel
Befund aus P-0014: Für die Sichtabnahme fehlen ausgefüllte Zustände: ein Chat mit eigenen und empfangenen Nachrichten (auch einer längeren), ein ausgefüllter Treffvorschlag samt unterem Formularteil und ein bestätigtes Treffen. Ein Spieltest erzeugt diese Bilder wie ein Nutzer.

## Dateien
- `playtests/design_voll.gd` – neuer Spieltest (Vorlagen: `playtests/ablauf.gd` für Chat und Treffen, `playtests/design.gd` für Speicherdatei und Bilder)

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` liefert „Gefüllter Chat und Treffvorschlag im neuen Stil“.
- Eigene Speicherdatei `const STORE := "user://spieltest_design_voll.json"`, am Anfang und am Ende löschen (wie in `design.gd`), dazwischen `scene.use_store(STORE)`.
- **Nach jedem `shot(...)` folgt `await wait(0.3)`** (das Bild entsteht erst im nächsten Frame).
- Ablauf:
  1. Match zwischen p01 und p02 herstellen wie in `design.gd`.
  2. Als p02 im Chat „Hi Alex, Lust auf Techniktraining am Samstag?“ senden; Perspektive zu p01 wechseln, Chat öffnen, „Klingt gut! Ich bringe Pratzen mit. Wollen wir uns im Stadtpark treffen? Dort ist genug Platz auf der Wiese und es gibt Schatten.“ senden; dann „Gern, 10 Uhr?“. `shot("chat_voll")`. `check`, dass `messages_box.get_child_count()` 3 ist.
  3. Treffen öffnen, Ort „Stadtpark, Wiese am Teich“, Datum „24.10.2026“, Uhrzeit „10:30“ eintragen, Vorschlag senden (wie in `ablauf.gd`). `shot("treffen_oben")`. Dann die `ScrollContainer` des Treffen-Bildschirms ganz nach unten scrollen (`scroll_vertical` auf einen großen Wert, z. B. 10000), `await wait(0.3)`, `shot("treffen_unten")`.
  4. Zu p02 wechseln, Treffen öffnen und zustimmen wie in `ablauf.gd`, `shot("treffen_bestaetigt")`.
- Der Spieltest wird vom Review ausgeführt; `verify.cmd` muss grün bleiben (das Skript muss fehlerfrei laden).

## Tests
Keine Unit-Tests; der Spieltest selbst ist die Prüfung.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0504 erhalten.
