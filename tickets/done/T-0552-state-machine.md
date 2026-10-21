---
id: T-0552
title: StateMachine – Zustandsautomat als Verhaltenskomponente
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „Spielverhalten durch klar definierte Verhaltenskomponenten“: ein einfacher Zustandsautomat (z. B. Gegner: ruhen, laufen, getroffen), den Editor und Agenten ohne Script konfigurieren können.

## Dateien
- `core/state_machine.gd` – neu, Klasse `StateMachine`
- `tests/test_state_machine.gd` – neu

## Akzeptanzkriterien
`class_name StateMachine`, `extends RefCounted`.
- `var current := ""`, `var transitions: Dictionary = {}` (Schlüssel `"von|ereignis"` → Zielzustand), `var history: Array[String] = []`
- `func _init(start: String = "") -> void`: `current = start`; ist `start` nicht leer, an `history` anhängen
- `func add(from: String, event: String, to: String) -> void`: `from` darf `"*"` sein (gilt in jedem Zustand)
- `func target_for(event: String) -> String`: zuerst `"<current>|<event>"`, dann `"*|<event>"`, sonst ""
- `func can(event: String) -> bool`: `target_for(event)` nicht leer
- `func send(event: String) -> bool`: Ziel vorhanden → `current = ziel`, an `history` anhängen, `true`; sonst `false`
- `func events() -> Array[String]`: alle Ereignisse, die im aktuellen Zustand möglich sind (eigene und `*`), ohne Doppelte, sortiert
- `func to_dict() -> Dictionary` (`current`, `transitions`, `history`) und `static func from_dict(d: Dictionary) -> StateMachine`

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var to: String = transitions.get(key, "")`); `history` beim Laden elementweise mit `str(...)` übernehmen.

## Tests
`tests/test_state_machine.gd`, `setup()`: `sm = StateMachine.new("idle")`, `sm.add("idle", "laufen", "walk")`, `sm.add("walk", "stopp", "idle")`, `sm.add("*", "treffer", "hurt")`:
- `test_wechsel`: `send("laufen")` wahr, `current` „walk“; nochmal `send("laufen")` falsch, `current` bleibt „walk“
- `test_jederzeit`: `send("treffer")` wahr, `current` „hurt“
- `test_ereignisse`: `events()` ist `["laufen", "treffer"]`; `can("stopp")` falsch
- `test_verlauf`: `send("laufen")`, `send("stopp")` → `history` ist `["idle", "walk", "idle"]`
- `test_speichern`: nach `send("laufen")` hat `StateMachine.from_dict(sm.to_dict())` `current` „walk“ und `send("stopp")` wahr

Review (21.10.2026): gemergt.
