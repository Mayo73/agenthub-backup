---
id: T-0360
title: Abnahmetest Kriterium 8 – kein Netzwerk, keine Standortfreigabe
project: sparring
priority: 3
---
## Ziel
Meilenstein „Abnahme“ (Abnahmekriterium 8: der Ablauf funktioniert ohne Netzwerk, ohne Anmeldung und ohne Standortfreigabe): Ein Test durchsucht alle Skripte nach Netzwerk- und Standortfunktionen und schlägt fehl, sobald eine auftaucht. Nur eine neue Testdatei.

## Dateien
- `tests/test_offline.gd` – neu

## Akzeptanzkriterien
- `extends "res://tests/base_test.gd"`
- `const FORBIDDEN: Array[String] = ["HTTPRequest", "HTTPClient", "StreamPeerTCP", "PacketPeerUDP", "WebSocketPeer", "TCPServer", "UDPServer", "ENetMultiplayerPeer", "OS.request_permission", "OS.shell_open"]`
- `func script_files() -> Array[String]`: alle Dateien in `res://scripts` (über `DirAccess.get_files_at("res://scripts")`), die auf `.gd` enden, als vollständiger Pfad `"res://scripts/<name>"`.
- `func findings() -> Array[String]`: für jede Datei den Inhalt mit `FileAccess.get_file_as_string(pfad)` lesen; für jedes Wort aus `FORBIDDEN`, das darin vorkommt, einen Eintrag `"<pfad>: <wort>"`.
- Gibt es `res://export_presets.cfg` (`FileAccess.file_exists`), darf deren Inhalt keine der Zeichenfolgen `"permissions/internet=true"`, `"permissions/access_fine_location=true"`, `"permissions/access_coarse_location=true"` enthalten. Fehlt die Datei, gilt der Teil als bestanden.

## Tests
- `test_skripte_gefunden`: `script_files()` enthält `"res://scripts/main.gd"` und `"res://scripts/ui_style.gd"`
- `test_kein_netzwerk`: `findings()` ist leer; Meldung bei Fehlschlag: `", ".join(findings())`
- `test_keine_android_rechte`: Prüfung der `export_presets.cfg` wie oben

Review (18.10.2026): nach 5 Versuchen fehlgeschlagen; mit genaueren Hinweisen neu eingeplant als T-0371.
