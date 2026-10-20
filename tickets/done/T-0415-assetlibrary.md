---
id: T-0415
title: AssetLibrary – Assets nach Format erkennen, aufnehmen und suchen
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 4: Import von Bild-, Audio- und 3D-Format, unterstützte Formate und Importfehler dokumentieren): Eine Asset-Bibliothek, die Dateien nach Endung einer Art zuordnet und nicht unterstützte Formate verständlich abweist.

## Dateien
- `core/asset_library.gd` – neu, Klasse `AssetLibrary`
- `tests/test_asset_library.gd` – neu

## Akzeptanzkriterien
`class_name AssetLibrary`, `extends RefCounted`:
- `const FORMATS := {"png": "bild", "jpg": "bild", "webp": "bild", "ogg": "audio", "wav": "audio", "mp3": "audio", "glb": "modell", "gltf": "modell"}`
- `var assets: Dictionary = {}` (Kennung → `{"id": String, "path": String, "kind": String, "name": String}`), `var next_id := 1`
- `static func kind_of(path: String) -> String`: Endung (`path.get_extension().to_lower()`) in `FORMATS` → Art, sonst „“
- `func add(path: String, name: String = "") -> CommandResult`: Art leer → `CommandResult.error(CommandResult.INVALID_ARGUMENT, "Format .%s wird nicht unterstützt" % endung)`; gleicher Pfad schon vorhanden → `CONFLICT`, `"Asset %s ist schon vorhanden"`; sonst Kennung `"a%d" % next_id` (dann `next_id += 1`), `name` leer → `path.get_file().get_basename()`, `success({"id": id, "kind": art})`
- `func remove(id: String) -> bool`
- `func list(kind: String = "") -> Array[Dictionary]`: Kopien, nach Kennungsnummer aufsteigend (`int(id.substr(1))`), bei nicht leerem `kind` nur diese Art
- `func find(text: String) -> Array[String]`: Kennungen (Reihenfolge wie `list`), deren `name` den Text ohne Groß-/Kleinschreibung enthält (`findn`)
- `static func supported_text() -> String`: „Bilder: png, jpg, webp · Audio: ogg, wav, mp3 · Modelle: glb, gltf“

## Tests
`tests/test_asset_library.gd`, `setup()`: `lib = AssetLibrary.new()`:
- `test_art`: `kind_of("res://a/Held.PNG")` „bild“, `kind_of("x.glb")` „modell“, `kind_of("x.txt")` „“
- `test_aufnehmen`: `add("res://bilder/held.png")` ok, `data["id"]` „a1“, `list()[0]["name"]` „held“
- `test_nicht_unterstuetzt`: `add("x.bmp")` → `code` „invalid_argument“, Meldung „Format .bmp wird nicht unterstützt“
- `test_doppelt`: zweimal derselbe Pfad → „conflict“
- `test_filter_und_suche`: `add("held.png")`, `add("musik.ogg")`, `add("burg.glb", "Große Burg")` → `list("audio").size()` 1, `find("burg")` `["a3"]`
- `test_entfernen`: aufnehmen, `remove("a1")` wahr, `list().size()` 0, `remove("a1")` falsch

Review (19.10.2026): gemergt, nachgebessert: nach Kennung statt Pfad abgelegt, Konfliktmeldung nennt den Pfad, Test test_doppelt_meldung.
