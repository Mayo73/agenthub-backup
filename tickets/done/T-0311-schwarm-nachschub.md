---
id: T-0311
title: FishSchool – fehlende Fische nachzählen und neu verteilen
project: zellenphase
priority: 3
after: T-0307
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Bisher wird das Meer leer, wenn der Spieler die Fische frisst. `FishSchool` soll berechnen, welche Arten fehlen und wo neue Fische auftauchen. Einbau in T-0312.

## Dateien
- `scripts/fish_school.gd`
- `tests/test_fish_school.gd` – Tests anhängen

## Akzeptanzkriterien
Am Ende von `scripts/fish_school.gd` anfügen (die Konstanten `SWARMS`, `SWARM_SIZE`, `GRAZERS`, `PUFFERS`, `PREDATORS` gibt es schon):
```gdscript
## Sollbestand je Art (wie im Startplan).
static func target_counts() -> Dictionary:
	return {"silberling": SWARMS * SWARM_SIZE, "grasfisch": GRAZERS, "kugelfisch": PUFFERS, "zackenbarsch": PREDATORS}


## Art-IDs der fehlenden Fische, alphabetisch sortiert (eine ID je fehlendem Fisch). fishes: Knoten mit species_id.
static func missing(fishes: Array) -> Array[String]:
	var have := {}
	for f in fishes:
		have[f.species_id] = int(have.get(f.species_id, 0)) + 1
	var out: Array[String] = []
	var counts := target_counts()
	for id: String in counts:
		for i in maxi(0, int(counts[id]) - int(have.get(id, 0))):
			out.append(id)
	out.sort()
	return out


## Stelle für einen nachkommenden Fisch: außer Sicht im Abstand MIN_DIST bis MAX_DIST um center.
static func respawn_position(center: Vector3, seed_value: int) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return _around(center, rng)
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_school.gd` anhängen. Für die Fische kleine Platzhalter benutzen: innere Klasse `class Stub:` mit `var species_id := ""` in der Testdatei und eine Hilfsfunktion `func stub(id: String) -> Stub`.
- `test_sollbestand`: `FishSchool.target_counts()["silberling"]` ist 12; die Summe aller Werte ist gleich `plan.size()`
- `test_nichts_fehlt`: für jeden Eintrag aus `plan` einen Stub mit dessen `"id"` → `FishSchool.missing(stubs)` ist leer
- `test_fehlende`: Stubs 10 × `"silberling"`, 3 × `"grasfisch"`, 2 × `"kugelfisch"`, 1 × `"zackenbarsch"` → `FishSchool.missing(stubs)` ist `["silberling", "silberling", "zackenbarsch"]`
- `test_zu_viele`: nur 5 × `"zackenbarsch"` → `missing()` enthält kein `"zackenbarsch"`
- `test_nachkommen_abstand`: für seed 1 bis 20: `var p := FishSchool.respawn_position(FishWorld.START, s)`; der waagrechte Abstand `Vector2(p.x - FishWorld.START.x, p.z - FishWorld.START.z).length()` ist ≥ `FishSchool.MIN_DIST` und ≤ `FishSchool.MAX_DIST + 0.01`; `FishWorld.depth_of(p)` liegt zwischen 5.0 und 50.0

Review (18.10.2026): gemergt.
