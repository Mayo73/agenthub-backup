---
id: T-0254
title: Spielermotor ohne Entfernungsdämpfung abspielen
project: drift
priority: 1
---
## Ziel
Die Tonanalyse zeigt: Beim Losfahren wird der eigene Motor leiser statt lauter. Ursache: Motor und Reifenquietschen des Spielerautos sind `AudioStreamPlayer2D`. Die Kamera schaut in Fahrtrichtung voraus (`LOOK_AHEAD`), der Zuhörer liegt also bei Tempo weit vor dem Auto, und Godot dämpft den Klang mit der Entfernung. Das eigene Auto soll immer gleich nah klingen: normale `AudioStreamPlayer`. Die KI-Autos (`scripts/ai_car.gd`) bleiben `AudioStreamPlayer2D`.

## Dateien
- `scripts/car.gd`
- `tests/test_car_sound.gd`

## Akzeptanzkriterien
- In `scripts/car.gd` die Deklarationen `var engine_player: AudioStreamPlayer2D` und `var squeal_player: AudioStreamPlayer2D` auf `AudioStreamPlayer` ändern, ebenso die beiden Zeilen `engine_player = AudioStreamPlayer2D.new()` und `squeal_player = AudioStreamPlayer2D.new()` auf `AudioStreamPlayer.new()`.
- Über `var engine_player` den Kommentar `## Eigener Motor ohne Entfernungsdämpfung (die Kamera schaut voraus, der Klang soll trotzdem nah bleiben).` ergänzen.
- `scripts/ai_car.gd` ist eine eigene Klasse und bleibt unverändert (KI-Motoren bleiben räumlich, `test_ai_car.gd` bleibt grün).
- Sonst nichts ändern.

## Tests
- `tests/test_car_sound.gd`: in `test_motor_vorhanden` die erste Prüfung auf `check(car.get_node("Engine") is AudioStreamPlayer, "Engine ist ein AudioStreamPlayer ohne Entfernungsdämpfung")` ändern und in `test_quietschen_vorhanden` die Prüfung auf `check(car.get_node("Squeal") is AudioStreamPlayer, "Squeal ist ein AudioStreamPlayer")`.
- Am Ende anhängen: `test_nicht_raeumlich`: `check(not (car.get_node("Engine") is AudioStreamPlayer2D), "Motor des Spielers ist nicht räumlich")` und dasselbe für `"Squeal"`.

Review (17.10.2026): gemergt.
