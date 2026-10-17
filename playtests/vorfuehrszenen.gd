extends "res://playtests/_zelle.gd"
## Alle Vorführszenen nacheinander abspielen. Im Filmlauf entsteht je Szene ein Bildstreifen,
## auf dem man Bewegung, Gift, Blitze und Treffer sieht.

## In diesen Szenen zeigt sich die Wirkung nur, wenn die Spielerzelle schwimmt.
const SWIM_SCENES := ["gift", "tempo", "wendigkeit"]


func describe() -> String:
	return "Alle Vorführszenen (%s) mit Bildstreifen je Szene" % ", ".join(DemoScenes.names())


func run() -> void:
	for scene_name in DemoScenes.names():
		await reload_scene()
		await start_demo(scene_name)
		check(not scene.in_menu, "Vorführszene %s startet ohne Menü" % scene_name)
		await wait(1.5)
		if scene_name in SWIM_SCENES:
			var dir := Vector2(1, 0.6) if scene_name == "wendigkeit" else Vector2.RIGHT
			target = scene.player.position + dir * 3000.0
		await film(scene_name, 3.0)
		stop_steering()
		measure(scene_name + "_ki_zellen", scene.ai_cells.size())
