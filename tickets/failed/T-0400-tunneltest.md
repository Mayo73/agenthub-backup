---
id: T-0400
title: Abnahmetest Ballistik – 100 schnelle Schüsse gegen dünne Wände ohne ausgelassenen Treffer
project: hub-engine
priority: 3
after: T-0398
---
## Ziel
Meilenstein „Ballistik“ (Abnahmekriterium 8): Ein Test feuert 100 festgelegte Projektile mit hoher Geschwindigkeit, verschiedenen Wandstärken und Winkeln und prüft, dass jedes genau einmal trifft. Der Bereich wird in `docs/BALLISTIK.md` festgehalten.

## Dateien
- `tests/test_ballistik_abnahme.gd` – neu
- `docs/BALLISTIK.md` – neu

## Akzeptanzkriterien
- `tests/test_ballistik_abnahme.gd` nutzt nur `Projectile2D` und Konstanten, keine Zufallszahlen.
- Versuchsraster: Geschwindigkeiten `[50.0, 150.0, 300.0, 600.0, 1000.0]` × Wandstärken `[0.01, 0.05, 0.2, 1.0]` × Winkel in Grad `[-40.0, -20.0, 0.0, 20.0, 40.0]` = 100 Versuche.
- Je Versuch: Start `(0, 0)`, Geschwindigkeit `Vector2.from_angle(deg_to_rad(winkel)) * v`, `gravity = 0`, `reaction = Projectile2D.REMOVE`, `lifetime = 1.0`, Wand `Rect2(5.0, -100.0, staerke, 200.0)`; `run(1.0, walls)` mit `var walls: Array[Rect2] = [wand]`.
- Erwartet je Versuch: `hits.size() == 1`, `alive` falsch, `absf(hits[0]["position"].x - 5.0) < 0.001`, `hits[0]["normal"] == Vector2(-1, 0)`.
- `docs/BALLISTIK.md` (deutsch, kurz): Einheiten (1 Einheit = 1 m), 120 Schritte/s, Prüfverfahren (Strecke je Schritt gegen Rechteck, `SweepHit`), das Versuchsraster oben, vereinfachte Annahmen (kein Luftwiderstand, Wände achsenparallel).

## Tests
- `test_hundert_versuche`: zählt Versuche und Fehlschläge; `check_eq(fehlschlaege, 0, "kein ausgelassener Treffer")` und `check_eq(versuche, 100, "100 Versuche")`
- `test_lebensdauer_ohne_wand`: `lifetime = 0.25`, `run(1.0, leer)` → `alive` falsch, `age` höchstens 0.26
- `test_rueckprall_energie`: `BOUNCE`, `restitution = 0.5`, `gravity = 0`, Geschwindigkeit `(100, 0)`, Wand wie oben (Stärke 0.05) → nach `run(0.2, walls)` `velocity.length()` ungefähr 50
