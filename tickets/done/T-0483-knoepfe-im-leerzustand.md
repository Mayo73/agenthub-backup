---
id: T-0483
title: Entdecken – Knopfreihe im Leerzustand ausblenden
project: sparring
priority: 2
---
## Ziel
Auftrag „Modernes Design“ (M9), Befund aus den Spieltestbildern: Sind keine Testprofile mehr übrig, stehen unter dem Leerzustand noch die Knöpfe „Überspringen“ und „Interesse“ (nur ausgegraut). Moderne Apps blenden sie dann aus.

## Dateien
- `scripts/discover_screen.gd`
- `tests/test_discover_screen.gd` – Test ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Variable `var action_row: HBoxContainer`; das ist die `HBoxContainer`, die heute in `_init()` als lokale Variable `hbox` die beiden runden Knöpfe aufnimmt (vorher lesen). Statt `var hbox := HBoxContainer.new()` also `action_row = HBoxContainer.new()` und überall `hbox` durch `action_row` ersetzen.
- In `refresh()`: im Zweig ohne Kandidaten `action_row.visible = false`, im Zweig mit Kandidat `action_row.visible = true`. `pass_button.disabled`/`like_button.disabled` bleiben wie bisher gesetzt.

## Tests
`tests/test_discover_screen.gd`:
- `test_knoepfe_im_leerzustand`: nach dem Aufbau (wie in den anderen Tests) ist `screen.action_row.visible` wahr; dann `screen.decide_pass()` so oft (höchstens 20-mal), bis `screen.current()` null ist → `screen.action_row.visible` falsch.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0483 erhalten.
