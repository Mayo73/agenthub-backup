---
id: T-0099
title: Tod, Wiedereinstieg und Gesundheitsanzeige
project: zellenphase
priority: 3
after: T-0098
---
## Ziel
Wie bei Spore schlüpft nach dem Tod sofort eine neue Zelle derselben Art: DNA und Größe bleiben, die Gesundheit ist wieder voll, kurz ist die Zelle unverwundbar, und nahe Angreifer verschwinden. Das HUD zeigt die Gesundheit und eine kurze Meldung.

## Dateien
- `scripts/hud.gd`
- `scripts/main.gd`
- `tests/test_hud.gd`: neue Tests anhängen, bestehende nicht ändern
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/hud.gd`:
  - neue Variablen unter `var stage_label: Label`: `var health_bar: ProgressBar`, `var message_label: Label`, `var message_time := 0.0`
  - in `_init()` am Ende:
```gdscript
	health_bar = ProgressBar.new()
	health_bar.name = "Health"
	health_bar.custom_minimum_size = Vector2(260, 14)
	health_bar.max_value = 100.0
	health_bar.value = 100.0
	health_bar.show_percentage = false
	health_bar.modulate = Color(1.0, 0.45, 0.45)
	box.add_child(health_bar)
	message_label = Label.new()
	message_label.name = "Message"
	message_label.add_theme_font_size_override("font_size", 30)
	message_label.position = Vector2(24, 980)
	add_child(message_label)
```
  - neue Funktionen am Ende:
```gdscript
func show_health(health: CellHealth) -> void:
	health_bar.value = health.ratio() * 100.0


## Zeigt eine Meldung für seconds Sekunden.
func show_message(text: String, seconds: float = 3.0) -> void:
	message_label.text = text
	message_time = seconds


func _process(delta: float) -> void:
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.text = ""
```
- `scripts/main.gd`:
  - neue Konstante oben: `const RESPAWN_INVULNERABLE := 2.0`
  - neue Variable unter `var player_health := CellHealth.new()`: `var deaths := 0`
  - in `_physics_process` als letzte Zeile (nach `resolve_combat()`): `check_death()`
  - in `_process` als letzte Zeile: `hud.show_health(player_health)`
  - neue Funktion am Ende:
```gdscript
## Nach dem Tod schlüpft eine neue Zelle: DNA und Größe bleiben, nahe KI-Zellen verschwinden.
func check_death() -> void:
	if not player_health.is_dead():
		return
	deaths += 1
	player_health.reset(RESPAWN_INVULNERABLE)
	player.motion.velocity = Vector2.ZERO
	var clear_dist := 400.0 * EcoSpawner.view_scale(player.radius)
	for cell in ai_cells.duplicate():
		if cell.position.distance_to(player.position) < clear_dist:
			remove_ai(cell)
	hud.show_message("Deine Zelle wurde gefressen – eine neue schlüpft.")
```

## Tests
- `tests/test_hud.gd`:
  - `test_gesundheit`: `var h := CellHealth.new()`, `h.damage(50.0)`, `hud.show_health(h)` → `hud.health_bar.value` ist 50.0
  - `test_meldung_verschwindet`: `hud.show_message("Hallo", 1.0)` → `hud.message_label.text` ist `"Hallo"`; `hud._process(1.5)` → `hud.message_label.text` ist `""`
- `tests/test_main_wiring.gd`:
  - `test_tod`: `main.progress.eat(5)`, `main.player_health.hp = 0.0`, `main.check_death()` → `main.deaths` ist 1, `main.player_health.hp` ist 100.0, `main.player_health.invulnerable` ist 2.0, `main.progress.dna` ist 5, `main.hud.message_label.text != ""`
  - `test_tod_vertreibt_gegner`: eine `AiCell` mit `setup("schnapper", Vector2(50, 0))` in `main.world` einhängen und an `main.ai_cells` anhängen; `main.player_health.hp = 0.0`, `main.check_death()` → `main.ai_cells.size()` ist 0
  - `test_lebend_nichts`: `main.check_death()` → `main.deaths` ist 0

Review (16.10.2026): gemergt.
