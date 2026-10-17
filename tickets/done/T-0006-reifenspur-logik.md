---
id: T-0006
title: Reifenspur-Logik
project: drift
priority: 3
---
## Ziel
Neue Klasse `SkidTrail`, die für ein Rad die Punkte seiner Reifenspuren sammelt: Solange das Rad eine Spur zieht, kommen Punkte dazu; hört es auf, endet die Spur; beim nächsten Mal beginnt eine neue. Damit der Speicher nicht volläuft, fallen die ältesten Punkte weg. Nur Logik und Tests, noch nicht ins Spiel einbauen.

## Dateien
- `scripts/skid_trail.gd`: neu, beginnt mit `class_name SkidTrail` und `extends RefCounted`
- `tests/test_skid_trail.gd`: neu

## Akzeptanzkriterien
- Konstanten: `const MIN_SEGMENT := 8.0` (Mindestabstand zwischen zwei Punkten in px), `const MAX_POINTS := 400` (höchstens so viele Punkte über alle Spuren zusammen)
- Variable: `var trails: Array[PackedVector2Array] = []` (alle Spuren, die letzte ist die aktuelle)
- `func update(point: Vector2, marking: bool) -> void`:
  - `marking` ist wahr und gerade läuft keine Spur: neue Spur mit diesem einen Punkt anhängen.
  - `marking` ist wahr und eine Spur läuft: Punkt nur anhängen, wenn er mindestens `MIN_SEGMENT` vom letzten Punkt der aktuellen Spur entfernt ist.
  - `marking` ist falsch: Die aktuelle Spur ist beendet (keine Punkte mehr anhängen).
  - Danach: Sind es zusammen mehr als `MAX_POINTS` Punkte, vorne von der ältesten Spur Punkte entfernen, bis es wieder `MAX_POINTS` sind. Leere Spuren aus `trails` entfernen.
- `func point_count() -> int`: Anzahl aller Punkte in allen Spuren.
- `func clear() -> void`: alle Spuren löschen.
- **Wichtig (GDScript-Falle):** `trails[i]` liefert eine **Kopie** des `PackedVector2Array`. Zum Ändern immer so vorgehen:
  ```gdscript
  var trail := trails[trails.size() - 1]
  trail.append(point)
  trails[trails.size() - 1] = trail
  ```

## Tests
Neue Datei `tests/test_skid_trail.gd` mit `extends "res://tests/base_test.gd"`. Lege in `setup()` einen `SkidTrail` an:
- `test_spur_beginnt_beim_markieren`: `update(Vector2(0, 0), true)` → `trails.size()` ist 1, `point_count()` ist 1
- `test_mindestabstand`: `update` mit `marking = true` für die Punkte (0,0), (3,0), (10,0), (12,0), (20,0) → `point_count()` ist 3
- `test_neue_spur_nach_pause`: (0,0) wahr, (10,0) wahr, (20,0) falsch, (30,0) wahr → `trails.size()` ist 2, `trails[1][0]` ist `Vector2(30, 0)`
- `test_ohne_markieren_keine_spur`: 5 Aufrufe mit `marking = false` → `trails.size()` ist 0
- `test_obergrenze`: 500 Aufrufe `update(Vector2(i * 10, 0), true)` für i von 0 bis 499 → `point_count()` ist 400 und der erste Punkt von `trails[0]` ist `Vector2(1000, 0)`
- `test_clear`: drei Punkte markieren, `clear()` → `point_count()` ist 0

Review (15.10.2026): gemergt. Korrektur: `clear()` setzt `is_trailing_active` zurück (sonst Absturz beim nächsten `update`), Test `test_clear_waehrend_spur` ergänzt.
