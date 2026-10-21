---
id: T-0457
title: EvolutionTimeline.summary_lines – Rückblick aus dem Zeitstrahl
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Der Rückblick (bisher im Abschlussbildschirm) soll aus dem Zeitstrahl kommen, damit er auch in der Fischphase verfügbar ist.

## Dateien
- `scripts/evolution_timeline.gd` – neue Funktionen
- `tests/test_evolution_timeline.gd` – Tests ergänzen

## Akzeptanzkriterien
Vorher `scripts/evolution_timeline.gd` lesen.
- `func count(kind: String) -> int`: Zahl der Einträge dieser Art
- `func phase_time(phase: String) -> float`: Zeit des letzten Eintrags mit dieser Phase minus Zeit des ersten Eintrags mit dieser Phase (0.0, wenn es keinen gibt)
- `func summary_lines() -> Array[String]`, genau in dieser Reihenfolge:
  - `"Entwicklungsschritte: %d" % size()`
  - `"Editorbesuche: %d" % count(EDITOR)`
  - `"Zeit als Zelle: %s" % time_text(phase_time("zelle"))`
  - nur wenn es Einträge mit Phase `"fisch"` gibt: `"Fischgrößen: %d" % count(FISH_SIZE)` und `"Verbesserungen: %d" % count(UPGRADE)`

## Tests
`tests/test_evolution_timeline.gd` ergänzen:
- `test_zaehlen`: Einträge START, STAGE, EDITOR, EDITOR → `count(EvolutionTimeline.EDITOR)` 2, `count(EvolutionTimeline.FISH)` 0
- `test_zeit_als_zelle`: Zelleinträge bei 10.0 und 130.0 → `phase_time("zelle")` 120.0; leerer Zeitstrahl → 0.0
- `test_zusammenfassung_zelle`: START (0 s), EDITOR (75 s) → genau 3 Zeilen: „Entwicklungsschritte: 2“, „Editorbesuche: 1“, „Zeit als Zelle: 1:15“
- `test_zusammenfassung_fisch`: dazu ein Eintrag FISH_SIZE mit Phase „fisch“ → 5 Zeilen, vierte „Fischgrößen: 1“, fünfte „Verbesserungen: 0“

Review (20.10.2026): gemergt, nachgebessert: Phase per Text "fisch" statt über die gleichlautende Art-Konstante FISH geprüft.
