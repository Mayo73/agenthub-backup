---
id: T-0236
title: Vorführszene „verschlingen“ für die Ein-Biss-Regel
project: zellenphase
priority: 2
after: T-0235
---
## Ziel
Der Nutzer möchte sehen, dass die Ein-Biss-Regel nur für deutlich kleinere Beute greift. Eine neue Vorführszene stellt die Spielerzelle (Fleischfresser, Abschnitt 2, Radius 27) vor einen kleinen Blasenling (Radius 12, wird verschluckt) und einen gleich großen Panzerling (Radius 27, wird nur verletzt).

## Dateien
- `scripts/demo_scenes.gd` – Eintrag in `SCENES`
- `tests/test_demo_scenes.gd` – eine Zahl anpassen
- `tests/test_main_verschlingen.gd` – zwei Tests anhängen
- `docs/zelltypen.md` – eine Zeile im Abschnitt „Vorführung“

## Akzeptanzkriterien
- In `scripts/demo_scenes.gd` in `SCENES` als letzten Eintrag (nach `"wendigkeit": …`) einfügen:
```gdscript
	"verschlingen": {"text": "Ein-Biss-Regel: Den kleinen Blasenling vorn verschluckst du mit einem Biss, den gleich großen Panzerling unten verletzt ein Biss nur.", "stage": 2, "diet": Diet.FLEISCHFRESSER, "parts": [], "ai": [["blasenling", Vector2(70, 0), 0.0], ["panzerling", Vector2(0, 140), 0.0]], "food": []},
```
- In `tests/test_demo_scenes.gd` die Zeile `check_eq(DemoScenes.names().size(), 8, "genau 8 Szenen")` durch `check_eq(DemoScenes.names().size(), 9, "genau 9 Szenen")` ersetzen (Funktionsname bleibt).
- In `docs/zelltypen.md` im Abschnitt `## Vorführung` am Ende der Liste der Startbefehle anfügen:
  `- \`-- --szene=verschlingen\`: Die Spielerzelle (Fleischfresser, Abschnitt 2) verschluckt den kleinen Blasenling mit einem Biss, den gleich großen Panzerling verletzt ein Biss nur. Zeigt die Ein-Biss-Regel.`
- Keine anderen Dateien ändern, keine Tests löschen.

## Tests
In `tests/test_main_verschlingen.gd` am Ende anhängen:
- `test_szene`: `main.start_scene("verschlingen")` → `main.ai_cells.size()` ist 2; `main.player.radius` ist 27.0; `main.ai_cells[0].species_id` ist `"blasenling"`; `main.ai_cells[1].species_id` ist `"panzerling"`
- `test_szene_regel`: `main.start_scene("verschlingen")`; `var klein: AiCell = main.ai_cells[0]`, `var gross: AiCell = main.ai_cells[1]`; `klein.motion.position = Vector2(35, 0)`; `gross.motion.position = Vector2(500, 500)`; `main.resolve_combat()` → `main.ai_cells.has(klein)` falsch; `main.ai_cells.has(gross)` wahr. Danach `gross.motion.position = Vector2(50, 0)`; `main.resolve_combat()` → `main.ai_cells.has(gross)` wahr; `gross.health.hp < gross.health.max_hp` wahr
