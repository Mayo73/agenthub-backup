---
id: T-0249
title: Fischphase – Spielerfisch, Riff, Kamera und Anzeige in der Fischszene
project: zellenphase
priority: 3
after: T-0240, T-0242, T-0243, T-0245, T-0246, T-0248
---
## Ziel
Die Fischszene wird spielbar: Der Spielerfisch (mit dem Ausbau aus der Zellenphase) schwimmt mit der Tastatur frei im 3D-Raum, die Kamera folgt ihm, am Boden wachsen Seegras und Felsen, Schwebeteilchen ziehen vorbei, die Anzeige zeigt die Tiefe. Zu Beginn erscheint der Übergangsbildschirm.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_main.gd` unter `var surface_mesh: MeshInstance3D` einfügen:
```gdscript
var player: FishPlayer
var reef: ReefView
var snow: MarineSnow
var hud: FishHud
var intro: FishIntro
var progress := FishProgress.new()
```
- In `_ready()` die beiden Zeilen `camera.position = FishWorld.START + Vector3(0.0, 2.0, 8.0)` und `camera.look_at(FishWorld.START)` ersetzen durch:
```gdscript

	player = FishPlayer.new()
	player.name = "Player"
	world.add_child(player)
	if FishStart.pending_build != null:
		player.set_build(FishStart.pending_build)
	progress.dna = FishStart.pending_dna
	FishStart.clear()

	reef = ReefView.new()
	reef.name = "Reef"
	world.add_child(reef)
	snow = MarineSnow.new()
	snow.name = "Snow"
	add_child(snow)
	hud = FishHud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.show_progress(progress)
	intro = FishIntro.new()
	intro.name = "Intro"
	add_child(intro)
	intro.open(player.build)

	camera.position = ChaseCamera.target_position(player.motion.position, player.motion.yaw, player.size)
	camera.look_at(player.motion.position)
```
  (Die Zeile `camera.current = true` bleibt danach stehen.)
- Nach `_ready()` (vor `## Tiefblaues Wasser …`) einfügen:
```gdscript
func _physics_process(delta: float) -> void:
	player.drive(FishInput.read(), delta)
	hud.show_depth(player.motion.depth())


## Kamera folgt weich und schaut auf den Fisch; die Schwebeteilchen bleiben bei der Kamera.
func _process(delta: float) -> void:
	var target := ChaseCamera.target_position(player.motion.position, player.motion.yaw, player.size)
	camera.position = ChaseCamera.follow(camera.position, target, delta)
	camera.look_at(player.motion.position)
	snow.position = camera.position
```
- Sonst nichts ändern.

## Tests
In `tests/test_fish_main.gd` ein `teardown()` gibt es schon (`fish.free()`); dort als zweite Zeile `FishStart.clear()` ergänzen. Am Ende anhängen:
- `test_spieler`: `fish.player is FishPlayer` wahr; `fish.player.get_parent() == fish.world` wahr; `fish.reef.get_parent() == fish.world` wahr; `fish.get_node("Hud") is FishHud` wahr; `fish.get_node("Snow") is MarineSnow` wahr; `fish.intro.visible` wahr
- `test_uebergabe`: `var b := FishBuild.new()`; `b.upgrade("schwanz")`; `FishStart.pending_build = b`; `FishStart.pending_dna = 33`; `var f2: Node3D = load("res://scenes/fish.tscn").instantiate()`; `(Engine.get_main_loop() as SceneTree).root.add_child(f2)` → `f2.player.build.level("schwanz")` ist 1; `f2.progress.dna` ist 33; `f2.hud.dna_label.text` ist `"DNA: 33"`; `FishStart.pending_build == null` wahr; am Ende `f2.free()`
- `test_ohne_uebergabe`: `fish.player.build.total_levels()` ist 0; `fish.progress.dna` ist 0
- `test_schwimmen`: `fish._physics_process(0.1)` → `fish.player.motion.position` ist `FishWorld.START`; `fish.hud.depth_label.text` ist `"Tiefe: 20 m"`; `fish.player.drive(Vector3(1, 0, 0), 0.1)` → `fish.player.position.z < 0.0` wahr
- `test_kamera`: `fish._process(10.0)` → `fish.camera.position.is_equal_approx(ChaseCamera.target_position(fish.player.motion.position, fish.player.motion.yaw, fish.player.size))` wahr; `fish.snow.position` ist `fish.camera.position`
