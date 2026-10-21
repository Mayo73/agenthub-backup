---
id: T-0550
title: UiLayout – einfache UI-Elemente mit Treffertest und Fokus
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „einfache UI-Elemente“: Knöpfe, Beschriftungen und Regler eines Spielmenüs als Modell. Treffertest und Fokusreihenfolge lassen sich so ohne Oberfläche prüfen und von Agenten bedienen.

## Dateien
- `core/ui_layout.gd` – neu, Klasse `UiLayout`
- `tests/test_ui_layout.gd` – neu

## Akzeptanzkriterien
`class_name UiLayout`, `extends RefCounted`.
- `const KINDS: Array[String] = ["button", "label", "slider"]`
- `var elements: Array[Dictionary] = []`, je `{"id": String, "kind": String, "rect": Rect2, "text": String, "enabled": bool, "value": float}`
- `func add(id: String, kind: String, rect: Rect2, text: String = "") -> CommandResult`: `kind` nicht in `KINDS` → `CommandResult.error(CommandResult.INVALID_ARGUMENT, "Unbekannte Art %s" % kind)`; Kennung schon vorhanden → `CommandResult.error(CommandResult.CONFLICT, "Element %s gibt es schon" % id)`; sonst anhängen mit `enabled` true und `value` 0.0, `CommandResult.success({"id": id})`
- `func find(id: String) -> Dictionary`: das Element oder `{}`
- `func hit_test(point: Vector2) -> String`: Elemente von hinten nach vorne durchgehen (zuletzt hinzugefügt liegt oben); nur aktive (`enabled`) und keine Beschriftungen (`label`); erstes mit `rect.has_point(point)` → seine Kennung; sonst ""
- `func set_enabled(id: String, on: bool) -> void`
- `func set_value(id: String, v: float) -> float`: nur für `slider`: `value = clampf(v, 0.0, 1.0)` speichern und zurückgeben; unbekannt oder kein Regler → −1.0
- `func focus_order() -> Array[String]`: Kennungen aller aktiven Elemente außer Beschriftungen, sortiert nach `rect.position.y`, bei gleichem y nach `rect.position.x`

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var r: Rect2 = e["rect"]`, `var on: bool = e["enabled"]`); zum Sortieren `sort_custom` mit einer Funktion `func(a: Dictionary, b: Dictionary) -> bool` verwenden.

## Tests
`tests/test_ui_layout.gd`, `setup()`: `ui = UiLayout.new()`:
- `test_anlegen`: `add("start", "button", Rect2(0, 0, 100, 40), "Start")` ok; dieselbe Kennung nochmal → `CommandResult.CONFLICT`; `add("x", "knopf", Rect2())` → `CommandResult.INVALID_ARGUMENT`
- `test_treffer`: Knöpfe „a“ `Rect2(0, 0, 100, 40)` und „b“ `Rect2(50, 0, 100, 40)`, Beschriftung „titel“ `Rect2(0, 100, 100, 20)` → `hit_test(Vector2(60, 10))` „b“, `hit_test(Vector2(10, 10))` „a“, `hit_test(Vector2(10, 110))` "", `hit_test(Vector2(500, 500))` ""
- `test_gesperrt`: wie oben, `set_enabled("b", false)` → `hit_test(Vector2(60, 10))` „a“
- `test_regler`: Regler „lautstaerke“; `set_value("lautstaerke", 1.5)` 1.0, `find("lautstaerke")["value"]` 1.0; Knopf „a“ → `set_value("a", 0.5)` −1.0
- `test_reihenfolge`: Knöpfe „unten“ `Rect2(0, 100, 50, 20)`, „rechts“ `Rect2(200, 0, 50, 20)`, „links“ `Rect2(0, 0, 50, 20)` → `focus_order()` ist `["links", "rechts", "unten"]`

Review (21.10.2026): gemergt.
