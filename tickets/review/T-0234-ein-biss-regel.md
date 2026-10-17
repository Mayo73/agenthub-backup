---
id: T-0234
title: Ein-Biss-Regel berechnen (CombatRules.can_swallow) und dokumentieren
project: zellenphase
priority: 2
---
## Ziel
Wunsch des Nutzers: Deutlich kleinere Zellen werden mit einem einzigen Biss ganz verschluckt, auch bei voller Gesundheit (wie in Spore). Dieses Ticket legt die Regel als Logik fest und dokumentiert sie; eingebaut wird sie in T-0235.

## Dateien
- `scripts/combat_rules.gd` – Konstante und zwei Funktionen anfügen
- `tests/test_combat_rules.gd` – Test anhängen
- `docs/zelltypen.md` – Abschnitt einfügen

## Akzeptanzkriterien
- In `scripts/combat_rules.gd` direkt unter der Zeile `const MEAT_PER_KILL := 3` einfügen:
```gdscript
## Ein-Biss-Regel: Beute mit höchstens SWALLOW_RATIO-mal so großem Radius wie der Angreifer
## wird mit einem Biss ganz verschluckt (bei den Größenabschnitten: mindestens zwei Abschnitte kleiner).
const SWALLOW_RATIO := 0.5
```
- Am Ende von `scripts/combat_rules.gd` anfügen:
```gdscript


## Ist die Beute deutlich kleiner, sodass ein Biss sie ganz verschluckt?
static func can_swallow(attacker_radius: float, target_radius: float) -> bool:
	return target_radius <= attacker_radius * SWALLOW_RATIO


## Nahrungswert einer verschluckten Zelle: so viel wie ihre Fleischbrocken zusammen.
static func swallow_value() -> int:
	return MEAT_PER_KILL * FoodField.MEAT_VALUE
```
- In `docs/zelltypen.md` direkt vor der Zeile `## Vorführung` diesen Abschnitt einfügen (mit Leerzeile davor und danach):
```markdown
## Ein-Biss-Regel
Eine Zelle gilt als deutlich kleiner, wenn ihr Radius höchstens halb so groß ist wie der Radius der Spielerzelle (`CombatRules.SWALLOW_RATIO` = 0,5). Bei den Größenabschnitten (Radius 12, 18, 27, 40 und 60 Pixel) heißt das: mindestens zwei Abschnitte kleiner. Beißt die Spielerzelle mit einem Mundwerkzeug für Fleisch (Fleisch- oder Allesfresser) eine solche Zelle, verschluckt sie sie mit einem Biss ganz, auch bei voller Gesundheit. Sie bekommt dann sofort so viel Nahrung, DNA und Wachstum wie die Fleischbrocken einer besiegten Zelle zusammen (`CombatRules.swallow_value()`, 3 × 2 = 6), und ein Beute-Teil wird wie bei einem Sieg freigeschaltet. Gleich große oder nur wenig kleinere Zellen verletzt ein Biss weiterhin nur. Vorbild ist Spore, wo kleine Zellen ebenfalls im Ganzen gefressen werden.
```
- Keine anderen Dateien ändern, keine Tests löschen oder ändern.

## Tests
In `tests/test_combat_rules.gd` am Ende anhängen:
- `test_verschlucken`: `CombatRules.can_swallow(27.0, 12.0)` wahr; `CombatRules.can_swallow(24.0, 12.0)` wahr (genau die Hälfte); `CombatRules.can_swallow(18.0, 12.0)` falsch; `CombatRules.can_swallow(60.0, 27.0)` wahr; `CombatRules.can_swallow(40.0, 27.0)` falsch; `CombatRules.can_swallow(27.0, 27.0)` falsch
- `test_verschlucken_wert`: `CombatRules.swallow_value()` ist 6
