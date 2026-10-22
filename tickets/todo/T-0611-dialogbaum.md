---
id: T-0611
title: DialogTree – verzweigte Gespräche mit Auswahl
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Gespräche mit Figuren als Baum aus Knoten mit Text und Antwortmöglichkeiten, aus einem Dictionary geladen (so kann ein KI-Agent sie als Daten schreiben).

## Dateien
- `core/dialog_tree.gd` – neu, Klasse `DialogTree`
- `tests/test_dialog_tree.gd` – neu

## Akzeptanzkriterien
`class_name DialogTree`, `extends RefCounted`. Daten: `{"start": "id", "nodes": {"id": {"text": "…", "choices": [{"text": "…", "next": "id2"}]}}}`; ein Knoten ohne `choices` (oder leere Liste) beendet das Gespräch.
- `var nodes := {}`, `var start := ""`, `var current := ""`
- `func load_data(data: Dictionary) -> Array[String]`: übernimmt `start` und `nodes` und gibt Fehler zurück (leer = gültig): `"Start fehlt"`, wenn `start` nicht in `nodes`; für jede Auswahl mit unbekanntem `next`: `"Unbekanntes Ziel: <next>"`. Danach `current = start`
- `func text() -> String`: Text des aktuellen Knotens, `""` wenn keiner
- `func choices() -> Array[String]`: Texte der Auswahlen des aktuellen Knotens
- `func choose(i: int) -> bool`: ungültiger Index → `false`; sonst `current` auf das Ziel, `true`
- `func finished() -> bool`: aktueller Knoten hat keine Auswahl
- `func restart() -> void`: `current = start`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_dialog_tree.gd` mit Hilfsfunktion `_daten() -> Dictionary`: Start `"hallo"`; `"hallo"` (Text „Hallo, Reisender!“, Auswahlen „Wer bist du?“ → `"wer"`, „Tschüss“ → `"ende"`), `"wer"` (Text „Ich bin der Wirt.“, Auswahl „Ach so“ → `"ende"`), `"ende"` (Text „Bis bald.“, keine Auswahl).
- `test_laden`: `load_data(_daten())` leer, `text()` „Hallo, Reisender!“, `choices()` hat 2 Einträge
- `test_verzweigen`: `choose(0)` → `text()` „Ich bin der Wirt.“; `choose(0)` → `finished()` wahr, `text()` „Bis bald.“
- `test_ungueltige_wahl`: `choose(5)` falsch, `choose(-1)` falsch, `text()` unverändert
- `test_neustart`: `choose(1)`, `restart()` → `text()` „Hallo, Reisender!“
- `test_fehler`: Start `"fehlt"` → Fehler enthält „Start fehlt“; ein Ziel `"nirgends"` → Fehler enthält „Unbekanntes Ziel: nirgends“