---
id: T-0416
title: AssetCommands – Assets über Befehle aufnehmen, auflisten, suchen und entfernen
project: hub-engine
priority: 3
after: T-0415
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 7: Assets ohne Klickautomation bearbeiten): Die Asset-Bibliothek über das gemeinsame Befehlsmodell bedienen.

## Dateien
- `core/asset_commands.gd` – neu, Klasse `AssetCommands`
- `tests/test_asset_commands.gd` – neu

## Akzeptanzkriterien
`class_name AssetCommands`, `extends RefCounted`. Nutzt `AssetLibrary` (`core/asset_library.gd`, vorher lesen).
- `static func register_all(commands: CommandRegistry, library: AssetLibrary) -> void` registriert mit Lambdas `func(args: Dictionary) -> CommandResult`:
  - `"asset.add"`, „Asset aufnehmen“, `{"path": "string", "name": "string"}` → Ergebnis von `library.add(path, name)`
  - `"asset.list"`, „Assets auflisten“, `{"kind": "string"}` → `success({"assets": library.list(kind)})`
  - `"asset.find"`, „Assets suchen“, `{"text": "string"}` → `success({"ids": library.find(text)})`
  - `"asset.remove"`, „Asset entfernen“, `{"id": "string"}` → `library.remove(id)` falsch → `NOT_FOUND`, `"Asset %s gibt es nicht"`; sonst `success({"id": id})`
  - `"asset.formats"`, „Unterstützte Formate“, `{}` → `success({"text": AssetLibrary.supported_text()})`

## Tests
`tests/test_asset_commands.gd`, `setup()`: `library = AssetLibrary.new()`, `registry = CommandRegistry.new()`, `AssetCommands.register_all(registry, library)`:
- `test_aufnehmen`: `asset.add` `{"path": "held.png", "name": ""}` ok, `data["kind"]` „bild“
- `test_liste`: zwei Assets (png, ogg), `asset.list` `{"kind": ""}` → 2, `{"kind": "bild"}` → 1
- `test_entfernen`: `asset.remove` „a9“ → „not_found“
- `test_formate`: `asset.formats` → `data["text"]` beginnt mit „Bilder:“
