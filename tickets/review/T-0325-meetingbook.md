---
id: T-0325
title: MeetingBook – Treffvorschläge mit beiderseitiger Zustimmung
project: sparring
priority: 3
---
## Ziel
Meilenstein „Demodaten und Profil“ (Datenmodell für „Treffen vereinbaren“): Pro Match gibt es höchstens einen Treffvorschlag mit Outdoor-Ort, Datum, Uhrzeit und Trainingsform. Bestätigt ist er erst, wenn beide zugestimmt haben; jede Änderung setzt die Zustimmung zurück (Abnahmekriterium 6). Absagen ist jederzeit möglich (Kriterium 7).

## Dateien
- `scripts/meeting_book.gd` – neu, Klasse `MeetingBook`
- `tests/test_meeting_book.gd` – neu

## Akzeptanzkriterien
`class_name MeetingBook`, `extends RefCounted`:
- `const FORMS: Array[String] = ["Techniktraining", "Drills", "Leichtes Sparring", "Konditionstraining"]`
- `const INTENSITIES: Array[String] = ["locker", "mittel", "intensiv"]`
- `var meetings: Dictionary = {}` – Match-ID → `{"place": "", "date": "", "time": "", "form": "", "intensity": "mittel", "rules": "", "approved": [], "cancelled_by": ""}`
- `static func missing_fields(details: Dictionary) -> Array[String]`: Liste der Probleme auf Deutsch, in dieser Reihenfolge:
  - `place` leer (nach `strip_edges()`) → `"Ort fehlt"`
  - `date` passt nicht zu `TT.MM.JJJJ` (RegEx `^\d{2}\.\d{2}\.\d{4}$`) → `"Datum fehlt oder ist ungültig (TT.MM.JJJJ)"`
  - `time` passt nicht zu `HH:MM` (RegEx `^([01]\d|2[0-3]):[0-5]\d$`) → `"Uhrzeit fehlt oder ist ungültig (HH:MM)"`
  - `form` nicht in `FORMS` → `"Trainingsform fehlt"`
- `func propose(match_id: String, by_id: String, details: Dictionary) -> Array[String]`: `details` enthält `place`, `date`, `time`, `form` und optional `intensity` (Standard „mittel“, muss in `INTENSITIES` sein, sonst „mittel“) und `rules` (Standard „“). Fehlt etwas (`missing_fields` nicht leer), nichts ändern und die Liste zurückgeben. Sonst Vorschlag speichern (Texte mit `strip_edges()`), `approved = [by_id]`, `cancelled_by = ""`, leere Liste zurückgeben. Ein bestehender Vorschlag wird dabei ersetzt; die Zustimmung des anderen ist damit weg.
- `func get_meeting(match_id: String) -> Dictionary`: Vorschlag oder `{}`.
- `func approve(match_id: String, user_id: String) -> void`: fügt `user_id` zu `approved` hinzu (keine Doppelten), nur wenn ein Vorschlag existiert und nicht abgesagt ist.
- `func is_confirmed(match_id: String, a_id: String, b_id: String) -> bool`: Vorschlag existiert, nicht abgesagt, `approved` enthält `a_id` und `b_id`.
- `func has_approved(match_id: String, user_id: String) -> bool`
- `func cancel(match_id: String, by_id: String) -> void`: setzt `cancelled_by = by_id` und leert `approved`.
- `func is_cancelled(match_id: String) -> bool`
- `func to_dict() -> Dictionary` mit `meetings`; `static func from_dict(d: Dictionary) -> MeetingBook`.

## Tests
`tests/test_meeting_book.gd`, in `setup()` `book = MeetingBook.new()` und `ok = {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}`:
- `test_vorschlag_gueltig`: `propose("m1","p01", ok)` gibt `[]`; `get_meeting("m1")["place"]` stimmt; `has_approved("m1","p01")` wahr; `is_confirmed("m1","p01","p02")` falsch
- `test_beide_stimmen_zu`: nach `propose` durch p01 `approve("m1","p02")` → `is_confirmed("m1","p01","p02")` wahr
- `test_aenderung_setzt_zurueck`: bestätigen, dann `propose("m1","p02", ok mit time "11:00")` → `is_confirmed` falsch, `has_approved("m1","p01")` falsch, `has_approved("m1","p02")` wahr
- `test_fehlende_angaben`: `propose("m1","p01", {})` gibt 4 Einträge, erster „Ort fehlt“; kein Vorschlag gespeichert
- `test_ungueltige_zeit_und_datum`: `date` „24.10.26“ und `time` „25:00“ → genau die zwei passenden Meldungen
- `test_intensitaet_und_regeln`: mit `intensity` „intensiv“ und `rules` „Kein Kopfkontakt“ → gespeichert; mit `intensity` „brutal“ → „mittel“
- `test_absagen`: bestätigen, dann `cancel("m1","p02")` → `is_cancelled` wahr, `is_confirmed` falsch; `approve("m1","p01")` danach ändert nichts; neuer `propose` hebt die Absage auf (`is_cancelled` falsch)
- `test_speichern_laden`: Vorschlag + Zustimmung, `MeetingBook.from_dict(book.to_dict())` → `is_confirmed` gleich
