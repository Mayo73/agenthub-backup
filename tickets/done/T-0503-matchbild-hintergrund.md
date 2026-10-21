---
id: T-0503
title: Match-Bildschirm – Hintergrund vollständig abdecken
project: sparring
priority: 2
---
## Ziel
Befund aus P-0014: Hinter dem „Match!“-Bildschirm schimmern noch die nächste Profilkarte („Mira, 26“), ihre Beschreibung und die grüne Matchmeldung durch. Der Match-Bildschirm soll den Entdecken-Bildschirm vollständig abdecken, mit einem ruhigen Verlauf statt einer halbdurchsichtigen Fläche.

## Dateien
- `scripts/match_overlay.gd`
- `tests/test_match_overlay.gd` – Test ergänzen (bestehende nicht ändern; gibt es die Datei nicht, neu anlegen)

## Akzeptanzkriterien
- Die bisherige lokale Variable `bg` wird zur Variable `var backdrop: ColorRect` mit `color = UiStyle.BG` (voll deckend, Alpha 1.0), weiterhin `PRESET_FULL_RECT` und `MOUSE_FILTER_IGNORE`.
- Neu darüber (direkt nach `backdrop`, vor dem `CenterContainer`): `var glow: TextureRect` mit `texture = UiStyle.vertical_gradient(Color(UiStyle.ACCENT, 0.35), Color(UiStyle.ACCENT, 0.0))`, `set_anchors_preset(Control.PRESET_FULL_RECT)`, `stretch_mode = TextureRect.STRETCH_SCALE`, `expand_mode = TextureRect.EXPAND_IGNORE_SIZE`, `mouse_filter = Control.MOUSE_FILTER_IGNORE`.
- Sonst ändert sich nichts (Knöpfe, Texte, Signale).

## Tests
`tests/test_match_overlay.gd`, `test_deckt_ab`: `var o := MatchOverlay.new()` → `o.backdrop.color.a` 1.0, `o.glow.texture` ist nicht null, `o.glow.get_index() == o.backdrop.get_index() + 1`; `o.free()`.

Review (20.10.2026): nicht gemergt, überholt durch den Neustart von Sparring als React-Native-App (Rückmeldung vom 20.10.2026). Branch als godot/T-0503 erhalten.
