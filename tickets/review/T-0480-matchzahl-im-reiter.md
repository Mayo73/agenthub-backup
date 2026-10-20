---
id: T-0480
title: Zahl der Matches im Reiter
project: sparring
priority: 2
after: T-0467
---
## Ziel
Auftrag „Modernes Design“ (M9): Der Reiter „Matches“ zeigt, wie viele laufende Matches die aktive Testperson hat, z. B. „Matches · 2“.

## Dateien
- `scripts/main.gd`
- `tests/test_main.gd` – Tests ergänzen (bestehende nicht ändern)

## Akzeptanzkriterien
- Neue Funktion `func update_badges() -> void` mit `##`-Kommentar: zählt die Matches aus `state.my_matches()` ohne `ended_by` (leer oder fehlend) und setzt `tab_buttons["matches"].text` auf `TAB_ICONS["matches"] + "\n" + TAB_TITLES["matches"]`, bei mindestens einem Match ergänzt um `" · %d" % anzahl`.
- `update_badges()` wird am Ende von `_ready()`, `show_screen()`, `show_chat()` und `_on_switched()` aufgerufen.

## Tests
- `test_reiter_zahl_start`: nach dem Start mit frischem Demozustand ist `tab_buttons["matches"].text` gleich `"♥\nMatches"`, ergänzt um `" · n"`, wenn n (Zahl der laufenden Matches aus `state.my_matches()`) größer 0 ist; den erwarteten Text im Test aus dem Zustand berechnen.
- `test_reiter_zaehlt_match`: zwei Testpersonen gegenseitig liken (wie in den bestehenden Tests), danach `update_badges()` → Text endet auf `" · %d" % n` mit n ≥ 1 aus `state.my_matches()`.
