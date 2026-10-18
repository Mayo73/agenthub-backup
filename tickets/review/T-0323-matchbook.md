---
id: T-0323
title: MatchBook – Interesse, Überspringen, gegenseitiges Match, Blockieren
project: sparring
priority: 3
---
## Ziel
Meilenstein „Demodaten und Profil“: Die Logik für das Swipe-Matching. Ein Match entsteht erst, wenn beide Personen Interesse bekundet haben (Abnahmekriterium 3). Unterschiedliche Kampfsportarten spielen dabei keine Rolle (Kriterium 4). Matches können beendet, Personen blockiert werden.

## Dateien
- `scripts/match_book.gd` – neu, Klasse `MatchBook`
- `tests/test_match_book.gd` – neu

## Akzeptanzkriterien
`class_name MatchBook`, `extends RefCounted`. Personen sind Profil-IDs (`String`).

- Felder:
  - `var likes: Dictionary = {}` – Schlüssel `"<von>><an>"` (z. B. `"p01>p02"`), Wert `true`
  - `var passes: Dictionary = {}` – gleiches Format
  - `var blocks: Dictionary = {}` – gleiches Format
  - `var matches: Array[Dictionary] = []` – Einträge `{"id": "m1", "a": "p01", "b": "p02", "ended_by": ""}`
  - `var next_id := 1`
- `static func key(from_id: String, to_id: String) -> String`: `from_id + ">" + to_id`
- `func like(from_id: String, to_id: String) -> String`: trägt das Interesse ein (nicht bei `from_id == to_id` oder wenn einer den anderen blockiert hat; dann `""`). Hat `to_id` schon Interesse an `from_id` und gibt es noch kein Match zwischen beiden, entsteht ein neues Match mit `id = "m%d" % next_id` (danach `next_id += 1`), `a = to_id` (wer zuerst wollte), `b = from_id`. Rückgabe: die ID des neu entstandenen Matches, sonst `""`. Doppeltes `like` erzeugt kein zweites Match.
- `func pass_on(from_id: String, to_id: String) -> void`: trägt in `passes` ein.
- `func has_swiped(from_id: String, to_id: String) -> bool`: `likes` oder `passes` enthält den Schlüssel.
- `func match_between(id1: String, id2: String) -> Dictionary`: das Match der beiden (Reihenfolge egal), sonst `{}`.
- `func get_match(match_id: String) -> Dictionary`: Match mit dieser ID oder `{}`.
- `func matches_of(user_id: String) -> Array[Dictionary]`: alle Matches mit `a` oder `b` gleich `user_id`, auch beendete, in Entstehungsreihenfolge.
- `func is_active(match_id: String) -> bool`: Match existiert und `ended_by` ist leer.
- `func end_match(match_id: String, by_id: String) -> void`: setzt `ended_by = by_id`, nur wenn `by_id` beteiligt und das Match noch aktiv ist.
- `static func other(m: Dictionary, user_id: String) -> String`: die andere Person des Matches.
- `func block(from_id: String, to_id: String) -> void`: trägt in `blocks` ein und beendet ein aktives Match der beiden (`ended_by = from_id`).
- `func is_blocked(id1: String, id2: String) -> bool`: einer hat den anderen blockiert.
- `func candidates(user_id: String, all_ids: Array[String]) -> Array[String]`: alle IDs aus `all_ids` in deren Reihenfolge, außer `user_id` selbst, schon gewischte (`has_swiped(user_id, id)`), blockierte (`is_blocked`) und solche, mit denen es schon ein Match gibt.
- `func to_dict() -> Dictionary` mit Schlüsseln `likes`, `passes`, `blocks`, `matches`, `next_id`; `static func from_dict(d: Dictionary) -> MatchBook` als Gegenstück (fehlende Schlüssel → leer bzw. 1; `next_id` als `int`; Matches als `Array[Dictionary]` übernehmen).

## Tests
`tests/test_match_book.gd`, in `setup()` `book = MatchBook.new()`:
- `test_einseitig_kein_match`: `like("p01","p02")` gibt `""`, `matches.size()` 0, `match_between("p01","p02")` ist `{}`
- `test_gegenseitig_match`: `like("p01","p02")`, dann `like("p02","p01")` gibt `"m1"`; `match_between("p02","p01")["id"]` ist `"m1"`; `a` ist `"p01"`, `b` ist `"p02"`
- `test_kein_doppeltes_match`: nach gegenseitigem Like noch einmal `like("p02","p01")` und `like("p01","p02")` → beide `""`, genau 1 Match
- `test_verschiedene_sportarten`: Like zwischen „p01“ und „p02“ in beide Richtungen ergibt ein Match (keine Prüfung der Sportart)
- `test_selbst_liken`: `like("p01","p01")` gibt `""`, `likes` leer
- `test_kandidaten`: `all = ["p01","p02","p03","p04"]`; `like("p01","p02")`, `pass_on("p01","p03")` → `candidates("p01", all)` ist `["p04"]`; `candidates("p02", all)` ist `["p01","p03","p04"]`
- `test_match_beenden`: Match erzeugen, `end_match("m1","p03")` (unbeteiligt) ändert nichts; `end_match("m1","p02")` → `is_active("m1")` falsch, `get_match("m1")["ended_by"]` ist `"p02"`; `matches_of("p01").size()` bleibt 1
- `test_blockieren`: Match p01/p02 erzeugen, `block("p01","p02")` → `is_blocked("p02","p01")` wahr, `is_active("m1")` falsch; `like("p02","p01")` gibt `""`; `candidates("p02", ["p01","p03"])` ist `["p03"]`
- `test_andere_person`: `other({"a":"p01","b":"p02"}, "p01")` ist `"p02"` und umgekehrt
- `test_speichern_laden`: Likes, Pass, Match und Block anlegen → `MatchBook.from_dict(book.to_dict())` liefert dieselben `likes`, `passes`, `blocks`, dieselbe Matchzahl und `next_id`; ein weiteres neues Match im geladenen Buch bekommt die nächste ID (z. B. `"m2"`)
