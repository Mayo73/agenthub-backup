---
id: T-0109
title: Teilefunde im Spiel einsammeln
project: zellenphase
priority: 3
after: T-0100, T-0105, T-0108
---
## Ziel
Solange noch Teile gesperrt sind, liegt in einiger Entfernung immer ein Teilefund. Berührt die Spielerzelle ihn, wird das nächste Teil freigeschaltet und eine Meldung erscheint.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variablen direkt unter `var backdrop: WaterBackdrop`:
```gdscript
var unlocks := PartUnlocks.new()
var pickups := PartPickups.new(13)
var pickup_view: PickupView
```
- In `_ready()` am Ende:
```gdscript
	pickup_view = PickupView.new()
	pickup_view.name = "Pickups"
	pickup_view.pickups = pickups
	world.add_child(pickup_view)
```
- In `_physics_process` direkt nach der Zeile `refill_food()` die Zeile `collect_pickups()` einfügen.
- Neue Funktion am Ende:
```gdscript
## Hält einen Teilefund in der Nähe bereit, solange noch Teile gesperrt sind.
## Berühren schaltet das nächste Teil frei.
func collect_pickups() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	pickups.remove_far(player.position, 2000.0 * spread)
	if pickups.positions.is_empty() and not unlocks.all_unlocked():
		pickups.spawn_around(player.position, 600.0 * spread, 1200.0 * spread)
	for i in pickups.take_touching(player.position, player.radius):
		var id := unlocks.next_locked()
		if unlocks.unlock(id):
			hud.show_message("Neues Teil gefunden: %s" % PartCatalog.name_of(id))
```
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` anhängen:
- `test_teilefund_liegt_bereit`: `main.pickups.positions.clear()`, `main.collect_pickups()` → `main.pickups.positions.size()` ist 1; `main.pickup_view.pickups == main.pickups` ist wahr; `main.pickup_view.get_parent() == main.world` ist wahr
- `test_teilefund_einsammeln`: `main.pickups.positions.clear()`, `main.pickups.positions.append(main.player.position)`, `main.collect_pickups()` → `main.unlocks.is_unlocked("geissel")` wahr; `main.hud.message_label.text` ist `"Neues Teil gefunden: Geißel"`; `main.pickups.positions.size()` ist 0
- `test_alle_frei_kein_fund`: jede ID aus `PartCatalog.UNLOCK_ORDER` mit `main.unlocks.unlock(id)` freischalten, `main.pickups.positions.clear()`, `main.collect_pickups()` → `main.pickups.positions.size()` ist 0

Review (16.10.2026): gemergt, nachgebessert: sieben Hilfsskripte des Agents (check_godot.bat, run_tests.sh u. a.) entfernt; Merge-Konflikt mit der T-0100-Nachbesserung aufgelöst.
