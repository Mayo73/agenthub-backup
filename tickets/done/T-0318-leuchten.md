---
id: T-0318
title: Leuchtende Fische bekommen ein Licht
project: zellenphase
priority: 3
after: T-0317
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Arten mit `"glow": true` (Laternenfisch, T-0317) leuchten in ihrer Farbe und erhellen das dunkle Wasser um sich.

## Dateien
- `scripts/ai_fish.gd`
- `tests/test_ai_fish.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Variable `var glow: OmniLight3D = null` unter `var model: FishModel`.
- In `setup(id, pos)` direkt vor dem abschließenden `sync()`:
```gdscript
	if glow != null:
		glow.free()
		glow = null
	if bool(d.get("glow", false)):
		glow = OmniLight3D.new()
		glow.name = "Glow"
		glow.light_color = d.get("color", Color.WHITE)
		glow.light_energy = 1.5
		glow.omni_range = 4.0 * size
		add_child(glow)
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_ai_fish.gd` anhängen (jeweils `var f := AiFish.new()`, am Ende `f.free()`):
- `test_laternenfisch_leuchtet`: `f.setup("laternenfisch", Vector3(0, -50, 0))` → `f.has_node("Glow")` wahr; `f.glow.light_color` ist `FishSpecies.data("laternenfisch")["color"]`
- `test_silberling_ohne_licht`: `f.setup("silberling", Vector3(0, -20, 0))` → `f.has_node("Glow")` falsch; `f.glow == null` wahr
- `test_zweimal_setup`: `f.setup("laternenfisch", Vector3(0, -50, 0))` zweimal → genau ein Kind, dessen Name mit `"Glow"` beginnt (über `get_children()` zählen)

Review (18.10.2026): gemergt.
