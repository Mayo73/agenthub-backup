# Architektur der Hub Engine

Stand 19.10.2026, Phase 1 (Grundlagen und Durchstich).

## Abgrenzung zu Godot

| Übernommen aus Godot 4.7 (MIT-Lizenz) | Eigene Entwicklung der Hub Engine |
|---|---|
| Renderer 2D/3D, Physik-Engines (Godot Physics, Jolt), Szenenbaum, Import von PNG/OGG/glTF, Windows-Export | Befehlsmodell für GUI, CLI und Agenten, Projekt- und Szenenmodell mit stabilen Kennungen und Revisionen, Schreibkoordinator, Module mit Vertrag, Ballistik-Komponente und Trefferprüfung, Testeingaben und Zustandsabfragen, Agent-Hub-Adapter, deutscher Editor |

Die Hub Engine ist kein eigener Renderer und kein eigener Physikkern.

## Schichten

1. **Kern (`core/`)**: reine Logik ohne Szenenbaum, vollständig automatisch getestet.
2. **Laufzeit-Adapter**: übersetzt das Szenenmodell in echte Godot-Nodes (2D und 3D) und meldet Zustände zurück.
3. **Zugänge**: Editor (Godot-Oberfläche in `scripts/`), CLI (`godot --headless --script`), MCP-Adapter für Agenten. Alle rufen dieselben Befehle auf.

## Geplante Kernmodule (Phase 1)

| Klasse | Aufgabe |
|---|---|
| `CommandResult` | Ergebnis eines Befehls: `code`, `message`, `data` |
| `CommandRegistry` | Befehle mit Namen, Beschreibung und Parameterschema registrieren und ausführen; Fähigkeitenverzeichnis |
| `SceneModel` | Objekte mit stabiler Kennung, Typ, Eltern, Eigenschaften; JSON |
| `WriteCoordinator` | Revisionen, Konflikterkennung bei veralteter Ausgangsrevision, Änderungsprotokoll |
| `UndoStack` | Rückgängig, Wiederholen, Checkpoints |
| `ModuleManifest`, `ModuleRegistry` | Modulvertrag, Abhängigkeiten, Aktivieren/Deaktivieren, Inkompatibles abweisen |
| `PathGuard` | erlaubte Projekt- und Ausgabeorte, alles andere `forbidden_path` |
| `Ballistics` | analytische Flugbahn, schrittweise Simulation mit 120 Hz, Abweichung |
| `SweepHit` | Trefferprüfung der Strecke zwischen zwei Schritten gegen Wände (keine Tunnel) |
| `InputSequence` | Testeingaben je Simulationsschritt, gehaltene und gleichzeitige Tasten, alles loslassen |

## Fehlercodes

`ok`, `unknown_command`, `invalid_argument`, `not_found`, `conflict`, `forbidden_path`, `dependency`, `incompatible`, `failed` (Konstanten in `CommandResult`).

## Einheiten

1 Szeneneinheit = 1 Meter, Schwerkraft 9,81 m/s² (2D nach +y, 3D nach −y), 120 Physikschritte pro Sekunde.
