---
id: T-0546
title: ImportCheck – unterstützte Formate erkennen und Importfehler melden
project: hub-engine
priority: 4
---
## Ziel
Muss 4: „Import mindestens eines Bild-, Audio- und offenen 3D-Formats; unterstützte Formate und Importfehler dokumentieren.“ Diese Klasse prüft vor dem Import Endung, Größe und Dateikopf und meldet Fehler verständlich.

## Dateien
- `core/import_check.gd` – neu, Klasse `ImportCheck`
- `tests/test_import_check.gd` – neu

## Akzeptanzkriterien
`class_name ImportCheck`, `extends RefCounted`, nur statische Funktionen.
- `const FORMATS: Dictionary = {"png": "bild", "jpg": "bild", "jpeg": "bild", "webp": "bild", "ogg": "audio", "wav": "audio", "mp3": "audio", "glb": "3d", "gltf": "3d", "obj": "3d"}`
- `static func kind_of(path: String) -> String`: Art zu `path.get_extension().to_lower()`, unbekannt → ""
- `static func check(path: String, size_bytes: int) -> CommandResult`: unbekannte Endung → `CommandResult.error(CommandResult.INCOMPATIBLE, "Format .%s wird nicht unterstützt" % endung)`; `size_bytes <= 0` → `CommandResult.error(CommandResult.INVALID_ARGUMENT, "Die Datei %s ist leer" % path.get_file())`; sonst `CommandResult.success({"kind": art, "extension": endung})`
- `static func header_ok(path: String, head: PackedByteArray) -> bool`: prüft die ersten 4 Bytes: png `0x89 0x50 0x4E 0x47`, glb `0x67 0x6C 0x54 0x46` („glTF“), ogg `0x4F 0x67 0x67 0x53` („OggS“), wav `0x52 0x49 0x46 0x46` („RIFF“); weniger als 4 Bytes → `false`. Andere bekannte Formate werden nicht geprüft → `true`. Unbekannte Endung → `false`
- `static func supported_text() -> String`: Gruppen „Bild“ (`bild`), „Audio“ (`audio`), „3D“ (`3d`) in dieser Reihenfolge, je `"<Titel>: "` und die Endungen alphabetisch mit `", "` verbunden; Gruppen mit `"; "` verbunden

Hinweis Typen: `var kind: String = FORMATS.get(ext, "")`; typisierte Arrays mit `var a: Array[String] = []` anlegen.

## Tests
`tests/test_import_check.gd`:
- `test_arten`: `kind_of("assets/Held.PNG")` „bild“, `kind_of("musik.ogg")` „audio“, `kind_of("level.glb")` „3d“, `kind_of("text.txt")` ""
- `test_pruefen`: `check("a.txt", 10).code` „incompatible“; `check("a.png", 0).code` „invalid_argument“; `check("a.png", 100)` ok mit `data.kind` „bild“
- `test_kopf`: `header_ok("a.png", PackedByteArray([0x89, 0x50, 0x4E, 0x47, 0x0D]))` wahr; mit `PackedByteArray([0, 1, 2, 3])` falsch; mit `PackedByteArray([0x89])` falsch; `header_ok("a.obj", PackedByteArray())` wahr
- `test_liste`: `supported_text()` ist `"Bild: jpeg, jpg, png, webp; Audio: mp3, ogg, wav; 3D: glb, gltf, obj"`

Review (21.10.2026): gemergt.
