---
id: T-0126
title: Zahlen für den Entwicklungsrückblick (RunStats)
project: zellenphase
priority: 5
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Am Ende eines Durchlaufs zeigt das Spiel einen Rückblick (Lastenheft, Soll „Entwicklungsrückblick“). Diese Klasse sammelt die Zahlen dazu, kann sie im Spielstand ablegen und als Textzeilen ausgeben. Der Einbau ins Spiel folgt später.

## Dateien
- `scripts/run_stats.gd`: neu
- `tests/test_run_stats.gd`: neu

## Akzeptanzkriterien
`scripts/run_stats.gd` mit `class_name RunStats`, `extends RefCounted`, Klassenkommentar `## Zahlen eines Durchlaufs für den Rückblick am Ende der Zellenphase.` und:
- Variablen: `var play_time := 0.0`, `var food_eaten := 0`, `var cells_defeated := 0`, `var deaths := 0`, `var editor_visits := 0`, `var diet_history: Array[String] = []` (Kommentar: Ernährung beim Erreichen jedes Größenabschnitts)
- `func tick(delta: float) -> void`: erhöht `play_time` um `delta`
- `func record_stage(diet: String) -> void`: hängt `diet` an `diet_history` an
- `func time_text() -> String`: Spielzeit als `"M:SS"`, z. B. 125 Sekunden → `"2:05"`. Minuten mit `floori(play_time / 60.0)`, Sekunden mit `int(play_time) % 60`, Format `"%d:%02d"` (keine Ganzzahl-Division mit `/`, sonst gibt Godot eine Warnung aus)
- `func main_diet() -> String`: häufigster Eintrag in `diet_history`; zählt in einer Schleife mit einem Dictionary mit und übernimmt einen Eintrag, sobald sein Zähler `>=` dem bisher besten ist (bei Gleichstand gewinnt also der zuletzt gleichgezogene). `""` bei leerem Verlauf
- `func summary_lines() -> Array[String]`: genau diese fünf Zeilen: `"Spielzeit: <time_text()>"`, `"Nahrung gefressen: <food_eaten>"`, `"Zellen besiegt: <cells_defeated>"`, `"Gestorben: <deaths>"`, `"Editorbesuche: <editor_visits>"`
- `func to_dict() -> Dictionary`: Schlüssel `"play_time"`, `"food_eaten"`, `"cells_defeated"`, `"deaths"`, `"editor_visits"`, `"diet_history"` (Kopie der Liste)
- `static func from_dict(d: Dictionary) -> RunStats`: neues Objekt; Zahlen mit `float(...)` bzw. `int(...)` aus `d.get(schlüssel, 0)`, negative Werte auf 0 begrenzen (`maxf`/`maxi`); `diet_history` aus `d.get("diet_history", [])` mit `str()` je Eintrag in einer Schleife füllen

## Tests
`tests/test_run_stats.gd` mit `extends "res://tests/base_test.gd"`, `var s: RunStats`, `setup()`: `s = RunStats.new()`.
- `test_zeit`: `s.tick(100.0)`, `s.tick(25.5)` → `s.time_text()` ist `"2:05"`; `RunStats.new().time_text()` ist `"0:00"`
- `test_hauptnahrung`: `s.main_diet()` ist `""`; `record_stage("pflanzenfresser")` zweimal, `record_stage("allesfresser")` einmal → `"pflanzenfresser"`; noch einmal `record_stage("allesfresser")` → `"allesfresser"`
- `test_zeilen`: `s.food_eaten = 12`, `s.cells_defeated = 3`, `s.tick(61.0)` → `s.summary_lines().size()` ist 5; `[0]` ist `"Spielzeit: 1:01"`; `[1]` ist `"Nahrung gefressen: 12"`; `[2]` ist `"Zellen besiegt: 3"`
- `test_speichern`: `s.deaths = 2`, `s.editor_visits = 4`, `s.record_stage("fleischfresser")`, `s.tick(10.0)`; `var t := RunStats.from_dict(s.to_dict())` → `t.deaths` ist 2, `t.editor_visits` ist 4, `t.play_time` ist 10.0, `t.diet_history.size()` ist 1, `t.diet_history[0]` ist `"fleischfresser"`
- `test_kaputte_werte`: `RunStats.from_dict({"deaths": -3, "play_time": -1.0})` → `deaths` ist 0, `play_time` ist 0.0, `food_eaten` ist 0

Review (16.10.2026): gemergt, nachgebessert: from_dict liest diet_history auch aus untypisiertem JSON-Array (Test test_aus_json ergänzt).
