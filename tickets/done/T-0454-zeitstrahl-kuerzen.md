---
id: T-0454
title: Zeitstrahl zeigt höchstens die letzten 12 Schritte
project: zellenphase
priority: 4
after: T-0439
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Nach langer Spielzeit hat der Zeitstrahl viele Einträge und die Leiste läuft aus dem Bild. Er zeigt deshalb nur die letzten 12 Schritte und davor einen Hinweis, wie viele frühere es gibt.

## Dateien
- `scripts/timeline_view.gd` – Begrenzung
- `tests/test_timeline_view.gd` – Tests ergänzen

## Akzeptanzkriterien
Vorher `scripts/timeline_view.gd` und `scripts/timeline_item.gd` lesen.
- `const MAX_ITEMS := 12`
- `var more_label: Label` (Name „More“, im `strip` ganz vorn, Schriftgröße 22, Farbe `Color(1, 1, 1, 0.7)`), wird in `_init` angelegt und von `show_timeline` nicht freigegeben
- `show_timeline(t)`: legt nur für die letzten `MAX_ITEMS` Einträge ein `TimelineItem` an. Gibt es mehr, steht in `more_label` `"+%d frühere" % anzahl` und es ist sichtbar, sonst unsichtbar
- `item_count()` zählt weiter nur die `TimelineItem`-Kinder (nicht `more_label`)

## Tests
`tests/test_timeline_view.gd` ergänzen:
- `test_viele_eintraege`: Zeitstrahl mit 20 Einträgen → `item_count()` 12, `more_label.visible` wahr, Text „+8 frühere“
- `test_wenige_eintraege`: 3 Einträge → `item_count()` 3, `more_label.visible` falsch
- `test_letzte_gezeigt`: 20 Einträge mit Beschriftung „S0“ … „S19“ → das letzte Kind von `strip` ist ein `TimelineItem` mit `entry["label"]` „S19“

Review (20.10.2026): gemergt.
