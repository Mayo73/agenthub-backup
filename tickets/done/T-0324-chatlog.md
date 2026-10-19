---
id: T-0324
title: ChatLog – Nachrichten je Match
project: sparring
priority: 3
---
## Ziel
Meilenstein „Demodaten und Profil“ (Datenmodell für den Demochat): Nachrichten zwischen zwei Testpersonen werden pro Match gespeichert. Ob ein Match noch aktiv ist, prüft später `AppState`; `ChatLog` speichert nur.

## Dateien
- `scripts/chat_log.gd` – neu, Klasse `ChatLog`
- `tests/test_chat_log.gd` – neu

## Akzeptanzkriterien
`class_name ChatLog`, `extends RefCounted`:
- `const MAX_LENGTH := 500`
- `var messages: Array[Dictionary] = []` – Einträge `{"match_id": "m1", "from": "p01", "text": "Hallo", "n": 1}`
- `var next_n := 1` – laufende Nummer, gibt die Reihenfolge an
- `func send(match_id: String, from_id: String, text: String) -> bool`: Text mit `strip_edges()` säubern; ist er leer, `false` und nichts speichern. Länger als `MAX_LENGTH` → auf `MAX_LENGTH` Zeichen kürzen. Sonst Eintrag mit `n = next_n` anhängen, `next_n += 1`, `true`.
- `func messages_for(match_id: String) -> Array[Dictionary]`: alle Nachrichten dieses Matches in Reihenfolge.
- `func last_message(match_id: String) -> Dictionary`: letzte Nachricht des Matches oder `{}`.
- `func count_for(match_id: String) -> int`
- `func to_dict() -> Dictionary` mit `messages` und `next_n`; `static func from_dict(d: Dictionary) -> ChatLog` (fehlend → leer bzw. 1; `n` und `next_n` als `int`).

## Tests
`tests/test_chat_log.gd`, in `setup()` `chat = ChatLog.new()`:
- `test_senden`: `send("m1","p01","Hallo")` ist `true`; `messages_for("m1").size()` 1; Text „Hallo“, `from` „p01“, `n` 1
- `test_leer_abgelehnt`: `send("m1","p01","   ")` ist `false`, keine Nachricht
- `test_leerzeichen_entfernt`: `send("m1","p01","  Hi  ")` speichert „Hi“
- `test_zu_lang_gekuerzt`: Text aus 600 „a“ → gespeicherter Text hat Länge 500
- `test_getrennt_nach_match`: zwei Nachrichten in „m1“, eine in „m2“ → `count_for("m1")` 2, `count_for("m2")` 1, `count_for("m3")` 0
- `test_reihenfolge_und_letzte`: „eins“, „zwei“, „drei“ in „m1“ → `messages_for` in dieser Reihenfolge, `last_message("m1")["text"]` „drei“, `last_message("m9")` ist `{}`
- `test_speichern_laden`: zwei Nachrichten senden, `ChatLog.from_dict(chat.to_dict())` → gleiche Nachrichten; nächste gesendete Nachricht hat `n` 3

Review (18.10.2026): gemergt, nachgebessert: from_dict kopiert Daten, next_id als int.
