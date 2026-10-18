---
id: T-0298
title: Doku der Fischarten (docs/fischarten.md)
project: zellenphase
priority: 4
---
## Ziel
Wie `docs/zelltypen.md` für die Zellenphase bekommt die Fischphase eine kurze Übersicht ihrer Arten aus `FishSpecies` (Silberling, Grasfisch, Zackenbarsch): Größe, Tempo, Verhalten, Gefahr und Nahrungswert. Ein Test hält Doku und Daten zusammen.

## Dateien
- `docs/fischarten.md` – neu
- `tests/test_doku_fischarten.gd` – neu

## Akzeptanzkriterien
- Neue Datei `docs/fischarten.md`, beginnt mit der Zeile `# Fischarten der Fischphase`, danach ein Satz Einleitung und je Art ein Abschnitt `## <Name>` (genau die Namen aus `FishSpecies.DATA[id]["name"]`: `## Silberling`, `## Grasfisch`, `## Zackenbarsch`). Jeder Abschnitt nennt in 2–4 Sätzen: Größe im Vergleich zum Spielerfisch am Anfang (Wert `size`), Verhalten (`schwarm` = bleibt im Schwarm und flieht, `scheu` = flieht allein, `jaeger` = jagt kleinere Fische), ob er beißt (`bite`, mit Schaden), und wie viel Nahrung er bringt (`food`). Die Zahlen müssen mit `scripts/fish_species.gd` übereinstimmen.
- Am Ende ein Abschnitt `## Tipps` mit 2–3 Sätzen: Pflanzenfresser fressen nur Algen, Fleisch- und Allesfresser können Silberlinge und Grasfische fressen; Zackenbarsche meiden, bis der eigene Fisch größer ist; Stacheln verletzen beißende Angreifer.
- Sonst nichts ändern.

## Tests
`tests/test_doku_fischarten.gd` (neu, `extends "res://tests/base_test.gd"`, `const PATH := "res://docs/fischarten.md"`):
- `test_datei`: Datei existiert; Text beginnt mit `"# Fischarten der Fischphase"`
- `test_alle_arten`: für jede `id` in `FishSpecies.ids()` enthält der Text `"## " + FishSpecies.data(id)["name"]`
- `test_tipps`: Text enthält `"## Tipps"`, und `"## Tipps"` steht nach `"## Zackenbarsch"` (über `find`)

Review (18.10.2026): gemergt.
