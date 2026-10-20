---
id: T-0417
title: BehaviorLibrary – Verhaltenskomponenten mit geprüften Parametern
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 4: erweiterbares Spielverhalten durch klar definierte Verhaltenskomponenten, Fehler verständlich melden): Eine Bibliothek fertiger Verhaltensarten mit Parameterbeschreibung und Prüfung, auf die Editor und Agenten zugreifen.

## Dateien
- `core/behavior_library.gd` – neu, Klasse `BehaviorLibrary`
- `tests/test_behavior_library.gd` – neu

## Akzeptanzkriterien
`class_name BehaviorLibrary`, `extends RefCounted`, nur statische Funktionen. Verhalten und Parameter (Name → `{"type": "number"|"string"|"bool", "min": float, "max": float, "default": Wert}`; `min`/`max` nur bei Zahlen):
- `"bewegen"`: „Bewegt das Objekt gleichmäßig.“ – `speed` (number, 0–1000, 100), `direction` (string, Standard „rechts“; erlaubt „links“, „rechts“, „hoch“, „runter“)
- `"drehen"`: „Dreht das Objekt dauerhaft.“ – `degrees_per_second` (number, −720–720, 90)
- `"zerstoeren_nach"`: „Entfernt das Objekt nach einer Zeit.“ – `seconds` (number, 0.1–600, 5)
- `"spielersteuerung"`: „Bewegt das Objekt mit den Eingabeaktionen.“ – `speed` (number, 0–1000, 200), `jump` (bool, false)

Funktionen:
- `static func names() -> Array[String]`: sortiert
- `static func description(name: String) -> String`: unbekannt → „“
- `static func defaults(name: String) -> Dictionary`: Parametername → Standardwert; unbekannt → `{}`
- `static func validate(name: String, params: Dictionary) -> Array[String]`, Probleme in dieser Reihenfolge: unbekanntes Verhalten → nur `"Verhalten %s gibt es nicht"`; je Schlüssel aus `params` (sortiert), der nicht vorgesehen ist → `"Unbekannter Parameter %s"`; je vorgesehenem Parameter (sortiert), der in `params` steht: falscher Typ → `"%s muss %s sein"` (Typ deutsch: „eine Zahl“, „ein Text“, „wahr oder falsch“); Zahl außerhalb → `"%s muss zwischen %s und %s liegen"` (Grenzen mit `str(...)`); bei `direction` ein nicht erlaubter Wert → `"direction muss links, rechts, hoch oder runter sein"`
- `static func create(name: String, params: Dictionary) -> CommandResult`: Probleme → `INVALID_ARGUMENT` mit den Problemen durch „; “ verbunden; sonst `success({"behavior": name, "params": defaults(name).merged(params, true)})`

## Tests
`tests/test_behavior_library.gd`:
- `test_namen`: `names()` ist `["bewegen", "drehen", "spielersteuerung", "zerstoeren_nach"]`
- `test_standard`: `defaults("bewegen")` hat `speed` 100.0 und `direction` „rechts“
- `test_gueltig`: `validate("drehen", {"degrees_per_second": 180.0})` leer
- `test_bereich`: `validate("bewegen", {"speed": 5000.0})` ist `["speed muss zwischen 0.0 und 1000.0 liegen"]`
- `test_typ_und_unbekannt`: `validate("spielersteuerung", {"jump": 1.0, "farbe": "rot"})` ist `["Unbekannter Parameter farbe", "jump muss wahr oder falsch sein"]`
- `test_anlegen`: `create("zerstoeren_nach", {})` ok, `data["params"]["seconds"]` 5.0; `create("fliegen", {})` → „invalid_argument“, Meldung „Verhalten fliegen gibt es nicht“

Review (19.10.2026): gemergt, nachgebessert: unbekannte Parameter sortiert gemeldet.
