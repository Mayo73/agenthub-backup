---
id: T-0467
title: Untere Leiste mit Symbolen
project: sparring
priority: 2
after: T-0464, T-0466
---
## Ziel
Auftrag „Modernes Design“ (M9): Die Reiterleiste unten bekommt Symbole über den Namen, wie in modernen Apps. Der aktive Reiter bleibt wie bisher hervorgehoben.

## Dateien
- `scripts/main.gd` – Reiter mit `UiStyle.icon_tab`
- `tests/test_main.gd` – Test ergänzen (bestehende Tests nicht ändern)

## Akzeptanzkriterien
- Neue Konstante in `Main`: `const TAB_ICONS := {"entdecken": "✦", "matches": "♥", "profil": "●"}`.
- In `_ready()` entstehen die Reiter mit `UiStyle.icon_tab(TAB_ICONS[screen_name], TAB_TITLES[screen_name])` statt `UiStyle.tab_button(...)`. Alles andere (Verbinden, `tab_buttons`, `disabled` für den aktiven Reiter) bleibt gleich.

## Tests
- `tests/test_main.gd`: `test_reiter_symbole`: nach dem Start enthält `tab_buttons["matches"].text` „♥“ und „Matches“, `tab_buttons["entdecken"].text` enthält „✦“ und „Entdecken“, `tab_buttons["profil"].text` enthält „●“ und „Profil“; `tab_buttons["entdecken"].disabled` ist wahr.
Review (20.10.2026): gemergt.
