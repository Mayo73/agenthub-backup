---
id: T-0326
title: AppState – Zustand der App mit aktiver Testperson
project: sparring
priority: 3
after: T-0322, T-0323, T-0324, T-0325
---
## Ziel
Meilenstein „Demodaten und Profil“: Ein Objekt hält den ganzen Zustand (Profile, Matches, Chat, Treffen) und weiß, aus wessen Perspektive die App gerade bedient wird. Alle Bildschirme ändern den Zustand nur über diese Klasse; sie prüft dabei die Regeln (z. B. keine Nachrichten in beendeten Matches, Abnahmekriterium 7).

## Dateien
- `scripts/app_state.gd` – neu, Klasse `AppState`
- `tests/test_app_state.gd` – neu

## Akzeptanzkriterien
`class_name AppState`, `extends RefCounted`:
- Felder: `var profiles: Array[SparProfile] = []`, `var active_id := "p01"`, `var book := MatchBook.new()`, `var chat := ChatLog.new()`, `var meetings := MeetingBook.new()`
- `static func demo() -> AppState`: `profiles = DemoData.profiles()`, `active_id = "p01"`, Rest leer.
- `func profile(id: String) -> SparProfile`: Profil mit dieser ID oder `null`.
- `func active() -> SparProfile`: `profile(active_id)`.
- `func all_ids() -> Array[String]`
- `func switch_to(id: String) -> bool`: nur bei vorhandener ID, setzt `active_id`.
- `func candidates() -> Array[SparProfile]`: Profile zu `book.candidates(active_id, all_ids())`.
- `func like(to_id: String) -> String` und `func pass_on(to_id: String) -> void`: über `book` aus Sicht von `active_id`.
- `func my_matches() -> Array[Dictionary]`: `book.matches_of(active_id)`, aber ohne Matches mit Personen, die `active_id` blockiert hat oder die `active_id` blockiert haben, **außer** das Match ist beendet (beendete bleiben sichtbar, damit das Ende aus beiden Perspektiven erkennbar ist).
- `func can_write(match_id: String) -> bool`: Match existiert, `active_id` ist beteiligt und `book.is_active(match_id)`.
- `func send_message(match_id: String, text: String) -> bool`: nur wenn `can_write`, dann `chat.send(match_id, active_id, text)`; sonst `false`.
- `func propose_meeting(match_id: String, details: Dictionary) -> Array[String]`: wenn nicht `can_write` → `["Match ist beendet"]`; sonst `meetings.propose(match_id, active_id, details)`.
- `func approve_meeting(match_id: String) -> void`: nur wenn `can_write`.
- `func cancel_meeting(match_id: String) -> void`: wenn `active_id` beteiligt (auch bei beendetem Match erlaubt).
- `func meeting_confirmed(match_id: String) -> bool`: `meetings.is_confirmed` mit beiden Personen des Matches.
- `func end_match(match_id: String) -> void`: `book.end_match(match_id, active_id)`; ein offener Treffvorschlag wird dabei mit `meetings.cancel(match_id, active_id)` abgesagt.
- `func block(to_id: String) -> void`: `book.block(active_id, to_id)`, ein Treffvorschlag des gemeinsamen Matches wird abgesagt.
- `func update_profile(changed: SparProfile) -> void`: ersetzt das Profil mit derselben ID durch eine Kopie (`duplicate_profile()`).
- `func to_dict() -> Dictionary` mit `version: 1`, `active_id`, `profiles` (Liste von `to_dict()`), `book`, `chat`, `meetings`; `static func from_dict(d: Dictionary) -> AppState` als Gegenstück. Fehlen Profile, `DemoData.profiles()` nehmen.

## Tests
`tests/test_app_state.gd`, in `setup()` `state = AppState.demo()`:
- `test_demo`: 8 Profile, `active().id` „p01“, keine Matches
- `test_perspektive_wechseln`: `switch_to("p02")` wahr, `active().name` „Sam“; `switch_to("x")` falsch, bleibt „p02“
- `test_match_aus_beiden_perspektiven` (Kriterium 3): als p01 `like("p02")` → `""`, `my_matches()` leer; wechseln zu p02, `like("p01")` ergibt „m1“; `my_matches().size()` 1; zurück zu p01 → `my_matches().size()` 1
- `test_unbeteiligte_sehen_nichts` (Kriterium 5): Match p01/p02 mit einer Nachricht; als p03 `my_matches()` leer und `send_message("m1","x")` falsch
- `test_nachricht_nach_ende` (Kriterium 7): Match p01/p02, als p01 `send_message` wahr; `end_match("m1")`; `send_message` falsch; `propose_meeting("m1", gültige Angaben)` gibt `["Match ist beendet"]`; als p02 ist das Match weiter in `my_matches()` und `can_write("m1")` falsch
- `test_treffen_bestaetigen` (Kriterium 6): Match p01/p02; als p01 `propose_meeting` mit gültigen Angaben (Ort „Stadtpark“, „24.10.2026“, „10:30“, „Drills“) → `[]`, `meeting_confirmed` falsch; als p02 `approve_meeting` → wahr
- `test_kandidaten_ohne_gewischte`: als p01 `pass_on("p03")` → `candidates()` hat 6 Profile, ohne p01 und p03
- `test_profil_aendern`: Kopie von `active()` mit `name = "Alexa"` → `update_profile`; `active().name` „Alexa“; Änderung an der Kopie danach wirkt nicht auf den Zustand
- `test_speichern_laden`: Match, Nachricht, Treffen, `switch_to("p02")` → `AppState.from_dict(state.to_dict())` hat `active_id` „p02“, 1 Match, 1 Nachricht, gleiches Treffen

Review (18.10.2026): gemergt.
