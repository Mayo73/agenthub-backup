---
id: T-0307
title: Vierte Fischart Kugelfisch – scheue Beute mittlerer Größe
project: zellenphase
priority: 3
after: T-0298
---
## Ziel
Die Fischphase bekommt eine vierte Art: den Kugelfisch, eine langsame, scheue Beute zwischen Silberling und Grasfisch. Zwei Kugelfische schwimmen in jeder Welt. Doku und Tests werden mitgezogen.

## Dateien
- `scripts/fish_species.gd` – neuer Eintrag
- `scripts/fish_school.gd` – zwei Kugelfische verteilen
- `docs/fischarten.md` – Abschnitt `## Kugelfisch`
- `tests/test_fish_species.gd`, `tests/test_fish_school.gd` – Erwartungen anpassen, Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_species.gd`: In `DATA` nach `"grasfisch"` einfügen:
```gdscript
	"kugelfisch": {"name": "Kugelfisch", "size": 0.8, "speed": 3.5, "hp": 30.0, "bite": 0.0, "behavior": "scheu", "color": Color(0.93, 0.74, 0.3), "food": 6, "sight": 8.0},
```
- `scripts/fish_school.gd`:
  - Neue Konstante unter `const GRAZERS := 3`: `const PUFFERS := 2`
  - In `spawn_plan()` nach der Schleife über `GRAZERS`:
```gdscript
	for i in PUFFERS:
		plan.append({"id": "kugelfisch", "position": _around(center, rng)})
```
- `docs/fischarten.md`: Abschnitt `## Kugelfisch` nach `## Grasfisch`, 2–3 Sätze wie bei den anderen Arten: Größe 0,8 (kleiner als der Spielerfisch am Anfang), Verhalten scheu (flieht allein), beißt nicht, Nahrungswert 6.
- Sonst nichts ändern.

## Tests
- `tests/test_fish_species.gd`: In der bestehenden Prüfung der sortierten Arten die Erwartung auf `["grasfisch", "kugelfisch", "silberling", "zackenbarsch"]` ändern (nicht löschen). Anhängen:
  - `test_kugelfisch`: `FishSpecies.has("kugelfisch")` wahr; `FishSpecies.is_predator("kugelfisch")` falsch; `FishSpecies.radius("kugelfisch")` ist 0.4; `FishSpecies.data("kugelfisch")["behavior"]` ist `"scheu"`
- `tests/test_fish_school.gd`: In der bestehenden Prüfung der Planlänge `17` auf `19` ändern (Text der Meldung mit anpassen: `"Plan hat 19 Einträge"`). Anhängen:
  - `test_kugelfische`: `FishSchool.spawn_plan(FishWorld.START, 7)` enthält genau 2 Einträge mit `"id" == "kugelfisch"`
- Der vorhandene Doku-Test `tests/test_doku_fischarten.gd` (`test_alle_arten`) muss danach weiterhin grün sein, weil er für jede Art den Abschnitt sucht.

Review (18.10.2026): gemergt, nachgebessert: Einrückung von FishSpecies.DATA bereinigt.
