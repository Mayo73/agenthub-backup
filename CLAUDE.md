# Zellenphase – Regeln für Agents

Evolutionsspiel in Godot 4.7 mit GDScript, Draufsicht auf eine Wasserwelt, nach dem Vorbild der Zellenphase von Spore. Die Spielerzelle schwimmt, frisst Pflanzen oder Fleisch, sammelt DNA, wächst in 5 Größenabschnitten, kämpft mit anderen Zellen und baut sich im Zelleditor um.

## Architektur (wichtig)

- Alles rechnet in **Weltkoordinaten von oben**: x nach rechts, y nach unten, Einheit Pixel. Winkel in Radiant, `0` = nach rechts (wie `Vector2.angle()`).
- Keine Godot-Physikkörper (`RigidBody2D`, `CharacterBody2D`, `Area2D`). Bewegung steckt in `CellMotion`, Berührungen werden mit Abständen gerechnet.
- Logik gehört in testbare Klassen (`extends RefCounted`), Nodes nur für Darstellung und Eingabe.
- Nodes werden **im Code** angelegt (`PlayerCell.new()`, `add_child(...)`), nicht in `.tscn`-Dateien. Die einzige Szene ist `scenes/main.tscn` mit `Main` → `World` (Spielwelt) und `Camera`.
- Neue Klassen bekommen ein `class_name`.

## Dateien

| Datei | Aufgabe |
|---|---|
| `scripts/main.gd` | Verdrahtung der Hauptszene: `world`, `camera` |
| `scripts/controls.gd` | `Controls`: Aktionen `hoch`, `runter`, `links`, `rechts`, `schwimmen` (linke Maustaste), `pause`; `Controls.key_vector()` |

Geplante Klassen (entstehen durch Tickets, Namen genau so verwenden): `CellMotion`, `PlayerInput`, `PlayerCell`, `CameraZoom`, `Diet`, `CellProgress`, `FoodItem`, `FoodField`, `MouthContact`, `FoodView`, `Hud`, `CellHealth`, `SpeciesCatalog`, `AiBrain`, `AiCell`, `EcoSpawner`, `CombatRules`, `ParallaxDots`, `WaterBackdrop`, `PartCatalog`, `CellBuild`, `CellStats`, `PartUnlocks`, `PartPickups`, `PickupView`, `PartGeometry`, `WeaponRules`, `PoisonClouds`, `ElectricOrgan`, `PartShapes`, `PartDrops`, `EditorSession`, `EditorSymmetry`, `CellLook`, `MateCall`, `SaveGame`, `EditorPreview`, `EditorHistory`, `EditorPlacement`, `CellEditorPanel`, `CellEditorCanvas`, `CellEditor`, `PartnerView`, `UserSettings`, `RunStats`, `MainMenu`, `PauseMenu`, `SettingsMenu`, `SoundSynth`, `MusicSynth`, `CellSounds`, `CellMusic`, `AudioBuses`, `GameAudio`, `PhaseEnd`, `EndScreen`, `TutorialHints`, `SaveSlots`, `SlotMenu`, `FpsMeter`, `Benchmark`, `CellBody`, `CellPattern`, `CellPainter`, `PartAnimation`, `EyeLook`, `HitFlash`, `DemoScenes`, `BubbleTrail`, `BubbleView`, `PartLooks`, `CellShading`, `DeathBursts`, `DeathBurstView`, `SpeciesParts`.

Menüs und Editor sind `CanvasLayer` bzw. `Node`, die ihre Bedienelemente im Code anlegen und Klicks per Signal melden; `main.gd` entscheidet, was passiert. Tests lösen Knöpfe mit `button.pressed.emit()` aus.

Teil-Lagen (`CellBuild`) sind in Zellradien relativ zur Zellmitte angegeben, Blickrichtung +x; `PartGeometry.world_point()` rechnet sie in Weltkoordinaten um.

## Fischphase (3D)

Nach der Zellenphase folgt eine Fischphase in einer echten 3D-Unterwasserwelt (Wunsch des Nutzers vom 17.10.2026).

- Eigene Szene `scenes/fish.tscn` mit `FishMain` (`scripts/fish_main.gd`, `extends Node3D`). Wie in der Zellenphase entstehen alle Knoten im Code; die Szene enthält nur den Wurzelknoten.
- Koordinaten in **Metern, y zeigt nach oben**. Wasseroberfläche bei `y = 0`, Meeresboden bei `y = -FishWorld.DEPTH`, Ränder bei ±`FishWorld.HALF_SIZE` in x und z. `FishWorld.clamp_to_water()` hält Lagen im Wasser.
- Blickrichtung wie in Godot: Bei `yaw = 0` und `pitch = 0` schwimmt der Fisch nach **-z**. Ein Node3D bekommt `rotation = Vector3(pitch, yaw, 0)`.
- Keine Godot-Physikkörper, auch nicht in 3D (`RigidBody3D`, `CharacterBody3D`, `Area3D`). Bewegung steckt in `FishMotion`, Berührungen werden mit Abständen gerechnet.
- Logik in `RefCounted`-Klassen mit Tests, Nodes (`Node3D`, `MeshInstance3D`, `CanvasLayer`) nur für Darstellung und Eingabe. Formen entstehen aus Godot-Grundkörpern (`SphereMesh`, `BoxMesh`, `PrismMesh`, `CylinderMesh`) mit `StandardMaterial3D`.
- Tests für die Fischszene laden `res://scenes/fish.tscn`, hängen sie an `(Engine.get_main_loop() as SceneTree).root` und geben sie in `teardown()` mit `free()` frei (Vorlage: `tests/test_fish_main.gd`).

| Datei | Aufgabe |
|---|---|
| `scripts/fish_world.gd` | `FishWorld`: Maße, Farben, `clamp_to_water()`, `depth_of()` |
| `scripts/fish_main.gd` | `FishMain`: `world`, `camera`, `sun`, `water`, `floor_mesh`, `surface_mesh` |

Geplante Klassen der Fischphase: `FishBuild`, `FishStart`, `FishIntro`, `FishMotion`, `FishInput`, `ChaseCamera`, `FishModel`, `FishPlayer`, `ReefLayout`, `ReefView`, `MarineSnow`, `FishHud`, `FishFood`, `FishFoodView`, `FishProgress`.

## Regeln

- GDScript 4 mit statischen Typen (`var x: int`, `func f() -> void`).
- Einrückung **nur mit Tabs**, niemals mit Leerzeichen.
- Kommentare beginnen mit `#` oder `##`. Es gibt keine Block-Kommentare mit `"""`.
- Zu jeder neuen Logik gehört ein Test in `tests/test_<thema>.gd`:

  ```gdscript
  extends "res://tests/base_test.gd"

  var progress: CellProgress

  func setup() -> void:          # optional, läuft vor jedem Test
  	progress = CellProgress.new()

  func test_beschreibung() -> void:
  	check_eq(ist_wert, soll_wert, "was geprüft wird")
  	check(bedingung, "was schiefging")
  ```

  Jeder Test bekommt eine frische Instanz der Testklasse; `setup()` und `teardown()` sind optional. `check_eq` vergleicht Zahlen mit `is_equal_approx`.
- Tests für die Hauptszene stehen in `tests/test_main_wiring.gd` (Szene in `setup()` laden, in `teardown()` mit `free()` freigeben).
- `project.godot` nur ändern, wenn das Ticket es ausdrücklich verlangt.
- Niemals Tests löschen oder abschwächen, nur damit die Prüfung grün wird.

## Stil (Grafik)

Bis Medien aus Higgsfield kommen, zeichnen die Nodes mit `_draw()` einfache Platzhalter (Kreise, Polygone).

- Weiche, organische Formen, leicht durchscheinend; Wasser tiefblau bis türkis (Hintergrund `#0B2B3D`).
- Farben: Pflanzennahrung grün (`#6CCB5F`), Fleisch rot (`#D9534F`), Spielerzelle hell (Türkis `#7FE0D0`), Gefahren mit kräftigen Warnfarben (Orange, Violett).
- Die Spielerzelle muss sich immer klar von anderen Zellen und von Nahrung abheben.
- Licht kommt immer von oben links auf dem Bildschirm (Schatten nach unten rechts, Glanzlicht oben links, `CellShading`), unabhängig von der Drehung der Zelle.
- Teile werden mit `PartLooks` gezeichnet (eigene Form und Farbe je Teil); `PartShapes` ist nur noch der alte Platzhalter.

### Bilder aus Higgsfield

Fertige Bilder liegen unter `assets/` und werden mit `preload("res://assets/...")` geladen (Pfade nennt das Ticket). Gezeichnet wird mit `draw_texture_rect(...)` bzw. `TextureRect`.

- Draufsicht auf eine Unterwasser-Mikrowelt, weiche organische Formen, leicht durchscheinend, sanfte Biolumineszenz.
- Sprites als PNG mit Transparenz; Wasserhintergrund `assets/water/wasser_tiefe.png` ist 1024 × 1024 und nahtlos kachelbar.
- Keine Schrift in Bildern, keine Marken, Logos oder bekannten Figuren.
- Zellkörper: `assets/cells/zellkoerper.png` ist fast weiß und wird mit der Zellfarbe eingefärbt (`CellPainter.draw_cell`); alle Zellen (Spieler, KI, Partner, Editor) zeichnen ihren Körper damit.

## Audio

Alle Klänge entstehen im Code (`SoundSynth`, `MusicSynth`, keine Audiodateien). Musik läuft über den Bus „Musik“, alles andere über „Effekte“ (`AudioBuses`).
