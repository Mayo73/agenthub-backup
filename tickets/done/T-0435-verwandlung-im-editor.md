---
id: T-0435
title: Verwandlung im Editor zeigen
project: zellenphase
priority: 4
after: T-0433, T-0434
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Nach dem Klick auf „Zum Fisch entwickeln“ verwandelt sich die Zelle auf der Arbeitsfläche des Editors in den Fisch, dann blendet das Bild ins Wasserblau.

## Dateien
- `scripts/cell_editor_canvas.gd` – Zelle gestreckt und mit wachsender Schwanzflosse zeichnen
- `scripts/cell_editor.gd` – Verwandlung abspielen
- `tests/test_cell_editor.gd` – Test ergänzen

## Akzeptanzkriterien
- `cell_editor_canvas.gd`: `var morph: FishMorph = null`. Ist `morph` gesetzt, wird der Zellkörper in x um `morph.stretch()` gestreckt gezeichnet (mit `draw_set_transform(mitte, 0.0, Vector2(morph.stretch(), 1.0))` vor dem Körper, danach `draw_set_transform(Vector2.ZERO)`) und hinter der Zelle (Seite −x) ein Dreieck als Schwanzflosse in der Zellfarbe mit Länge `morph.tail() * radius`. Teile werden während der Verwandlung nicht gezeichnet.
- `cell_editor.gd`: `signal morph_finished`; `var morph := FishMorph.new()`; `var fade_rect: ColorRect` (Name „Fade“, ganzer Bildschirm, Farbe `FishWorld.WATER_COLOR` mit Alpha 0, als letztes Kind im `view_layer`, `mouse_filter` ignorieren)
  - `func play_morph() -> void`: `morph.start()`, `canvas.morph = morph`, alle Knöpfe deaktivieren
  - `_process(delta)`: läuft die Verwandlung oder ist sie gerade fertig geworden: `morph.tick(delta)`, `canvas.queue_redraw()`, `fade_rect.color.a = morph.fade()`; sobald `morph.is_done()`, genau einmal `morph_finished` senden

## Tests
`tests/test_cell_editor.gd`:
- `test_verwandlung`: Editor öffnen, `play_morph()`, dann `_process(1.0)` → `canvas.morph != null`, `fade_rect.color.a` 0.0; `_process(2.3)` (gesamt 3.3 s) → `morph_finished` kam genau einmal an (Zähler über ein Lambda), `fade_rect.color.a` 1.0; ein weiteres `_process(1.0)` sendet es nicht noch einmal

Review (20.10.2026): selbst umgesetzt. Der Agent scheiterte 5-mal an der Zeitsteuerung (änderte zuletzt sogar FishMorph). Die Blende liegt auf einer eigenen Ebene (Layer 6) über der Bedienleiste statt im view_layer, sonst bliebe die Leiste sichtbar. Dazu Test test_ohne_verwandlung.
