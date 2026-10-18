---
id: T-0317
title: Fünfte Art – Laternenfisch in der Tiefe
project: zellenphase
priority: 3
after: T-0311, T-0298
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Die Tiefe soll sich lohnen. Leuchtende Laternenfische leben nur unten (45 bis 58 m) und sind wertvolle Beute. Das Leuchten folgt in T-0318.

## Dateien
- `scripts/fish_species.gd` – neuer Eintrag
- `scripts/fish_school.gd` – Laternenfische verteilen und mitzählen
- `docs/fischarten.md` – neuer Abschnitt
- `tests/test_fish_species.gd`, `tests/test_fish_school.gd` – Erwartungen anpassen, Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_species.gd`: In `DATA` nach `"kugelfisch"` einfügen:
```gdscript
	"laternenfisch": {"name": "Laternenfisch", "size": 0.7, "speed": 5.0, "hp": 25.0, "bite": 0.0, "behavior": "scheu", "color": Color(0.25, 0.85, 0.95), "food": 10, "sight": 9.0, "glow": true},
```
- `scripts/fish_school.gd`:
  - Neue Konstanten direkt unter `const PUFFERS := 2`:
```gdscript
const LANTERNS := 3
## Laternenfische leben nur so tief (Meter, von–bis).
const LANTERN_DEPTH := Vector2(45.0, 58.0)
```
  - In `spawn_plan()` direkt vor der Schleife über `PREDATORS`:
```gdscript
	for i in LANTERNS:
		var p := _around(center, rng)
		p.y = -rng.randf_range(LANTERN_DEPTH.x, LANTERN_DEPTH.y)
		plan.append({"id": "laternenfisch", "position": FishWorld.clamp_to_water(p)})
```
  - In `target_counts()` den Eintrag `"laternenfisch": LANTERNS` ergänzen.
  - `respawn_position()` nicht ändern.
- `docs/fischarten.md`: Abschnitt `## Laternenfisch` nach `## Kugelfisch`, 2–3 Sätze wie bei den anderen Arten: Größe 0,7, lebt nur in 45 bis 58 m Tiefe, scheu, beißt nicht, leuchtet, Nahrungswert 10.
- Sonst nichts ändern.

## Tests
- `tests/test_fish_species.gd`: In der bestehenden Prüfung der sortierten Arten die Erwartung auf `["grasfisch", "kugelfisch", "laternenfisch", "silberling", "zackenbarsch"]` ändern (nicht löschen). Anhängen:
  - `test_laternenfisch`: `FishSpecies.has("laternenfisch")` wahr; `FishSpecies.is_predator("laternenfisch")` falsch; `FishSpecies.data("laternenfisch")["glow"]` wahr; `FishSpecies.data("laternenfisch")["food"]` ist 10
- `tests/test_fish_school.gd`: In der bestehenden Prüfung der Planlänge `19` auf `22` ändern (Meldung `"Plan hat 22 Einträge"`). Anhängen:
  - `test_laternenfische_tief`: `FishSchool.spawn_plan(FishWorld.START, 7)` enthält genau 3 Einträge mit `"id" == "laternenfisch"`; für jeden ist `FishWorld.depth_of(entry["position"])` ≥ 45.0
  - `test_laternenfische_im_soll`: `FishSchool.target_counts()["laternenfisch"]` ist 3
- Der Doku-Test `tests/test_doku_fischarten.gd` muss grün bleiben (er sucht für jede Art einen Abschnitt).

Review (18.10.2026): gemergt, nachgebessert: nachkommende Laternenfische erscheinen in ihrer Tiefe (respawn_position), Test ergänzt, überflüssige Testschleife entfernt.
