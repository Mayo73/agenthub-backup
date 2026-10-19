---
id: T-0343
title: MeetingStatus – Stand eines Treffvorschlags verständlich beschreiben
project: sparring
priority: 3
after: T-0367
---
## Ziel
Meilenstein „Treffen vereinbaren“: Aus jeder Perspektive soll klar sein, wie es um das Treffen steht: kein Vorschlag, wartet auf Zustimmung, bestätigt oder abgesagt (Abnahmekriterien 6 und 7). Ein bestätigter Termin wird nicht als Verpflichtung dargestellt (Lastenheft „Freiwilligkeit“). Reine Logik, der Bildschirm folgt in T-0344.

## Dateien
- `scripts/meeting_status.gd` – neu, Klasse `MeetingStatus`
- `tests/test_meeting_status.gd` – neu

## Akzeptanzkriterien
`class_name MeetingStatus`, `extends RefCounted`:
- `enum Stage { NONE, WAITING_FOR_ME, WAITING_FOR_OTHER, CONFIRMED, CANCELLED }`
- `static func stage(state: AppState, match_id: String) -> int`: aus Sicht von `state.active_id`:
  - kein Vorschlag → `NONE`
  - abgesagt (`meetings.is_cancelled`) → `CANCELLED`
  - `state.meeting_confirmed(match_id)` → `CONFIRMED`
  - aktive Person hat nicht zugestimmt → `WAITING_FOR_ME`, sonst `WAITING_FOR_OTHER`
- `static func text(state: AppState, match_id: String) -> String`, mit dem Namen der anderen Person (`MatchBook.other`) bzw. dem Namen aus `cancelled_by`:
  - `NONE`: `"Noch kein Treffvorschlag."`
  - `WAITING_FOR_ME`: `"%s schlägt ein Treffen vor. Stimmst du zu?"`
  - `WAITING_FOR_OTHER`: `"Wartet auf die Zustimmung von %s."`
  - `CONFIRMED`: `"Von beiden bestätigt. Die Teilnahme bleibt freiwillig – ihr könnt jederzeit absagen."`
  - `CANCELLED`: `"Abgesagt von %s."` bzw. `"Abgesagt von dir."`, wenn die aktive Person abgesagt hat
- `static func summary(meeting: Dictionary) -> String`: eine Zeile `"<Ort> · <Datum>, <Uhrzeit> Uhr · <Form> · <Intensität>"`; ist `rules` nicht leer, folgt eine zweite Zeile `"Regeln: <rules>"`; bei leerem Dictionary `""`.
- `static func can_approve(state: AppState, match_id: String) -> bool`: `stage == WAITING_FOR_ME` und `state.can_write(match_id)`.
- `static func can_cancel(state: AppState, match_id: String) -> bool`: Vorschlag existiert und ist nicht abgesagt.

## Tests
`tests/test_meeting_status.gd`: in `setup()` `state = AppState.demo()`, Match p01/p02 erzeugen (als p01 `like("p02")`, `switch_to("p02")`, `like("p01")`, `switch_to("p01")`), `ok = {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}`.
- `test_kein_vorschlag`: `stage` `NONE`, `text` „Noch kein Treffvorschlag.“
- `test_warten`: als p01 `propose_meeting("m1", ok)` → `stage` `WAITING_FOR_OTHER`, `text` „Wartet auf die Zustimmung von Sam.“; als p02 `WAITING_FOR_ME`, `text` „Alex schlägt ein Treffen vor. Stimmst du zu?“, `can_approve` wahr
- `test_bestaetigt`: zusätzlich als p02 `approve_meeting("m1")` → `CONFIRMED`, Text enthält „freiwillig“; `can_approve` falsch
- `test_abgesagt`: bestätigt, dann als p02 `cancel_meeting("m1")` → als p02 „Abgesagt von dir.“, als p01 „Abgesagt von Sam.“; `can_cancel` falsch
- `test_zusammenfassung`: `summary` des Vorschlags (mit Standardintensität) ist „Stadtpark, Wiese am Teich · 24.10.2026, 10:30 Uhr · Drills · mittel“; mit `rules` „Kein Kopfkontakt“ zweite Zeile „Regeln: Kein Kopfkontakt“; `summary({})` „“
- `test_beendetes_match`: Vorschlag, als p01 `end_match("m1")` → als p02 `can_approve` falsch

Review (19.10.2026): gemergt, nachgebessert: can_cancel prüft, ob ein Vorschlag existiert.
