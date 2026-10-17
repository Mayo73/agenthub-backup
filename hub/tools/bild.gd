# Bildwerkzeug für Medien aus Higgsfield: freistellen, zuschneiden, skalieren, als PNG speichern.
# Läuft mit der Godot-Konsolenversion (Pfad: godotBin in config.json), ohne Projekt:
#   "<godot>" --headless --script C:/Users/wiens/AgentHub/hub/tools/bild.gd -- <eingabe> <ausgabe.png> [Optionen]
# Pfade absolut angeben. Optionen, ausgeführt in dieser Reihenfolge:
#   --key RRGGBB      Hintergrundfarbe transparent machen (z. B. ff00ff für Magenta)
#   --tolerance 0.12  Abstand zur Schlüsselfarbe (0–1), bis zu dem ein Pixel ganz transparent wird;
#                     bis zum doppelten Abstand läuft die Kante weich aus
#   --crop X,Y,B,H    Ausschnitt ab Pixel X,Y mit Breite B und Höhe H (z. B. für vergrößerte Details)
#   --trim            transparente Ränder abschneiden
#   --fit BxH         in das Rechteck einpassen, Seitenverhältnis bleibt
#   --size BxH        auf genau diese Größe skalieren
# Ausgabe: eine Zeile "BILD: ok <breite>x<höhe> <ausgabe>" (Exit-Code 0) oder "BILD: FEHLER …" (Exit-Code 1).
extends SceneTree


func _init() -> void:
	quit(_run(OS.get_cmdline_user_args()))


func _run(args: PackedStringArray) -> int:
	if args.size() < 2:
		return _fail("Aufruf: bild.gd -- <eingabe> <ausgabe.png> [--key RRGGBB] [--tolerance 0.12] [--trim] [--fit BxH] [--size BxH]")
	var input := args[0].replace("\\", "/")
	var output := args[1].replace("\\", "/")
	if input.is_relative_path() or output.is_relative_path():
		return _fail("Ein- und Ausgabe bitte als absolute Pfade angeben.")

	var key := ""
	var tolerance := 0.12
	var crop := Rect2i()
	var trim := false
	var fit := Vector2i.ZERO
	var size := Vector2i.ZERO
	var i := 2
	while i < args.size():
		var option := args[i]
		var value := args[i + 1] if i + 1 < args.size() else ""
		match option:
			"--key":
				if not Color.html_is_valid(value):
					return _fail("Ungültige Farbe für --key: " + value)
				key = value
				i += 1
			"--tolerance":
				if not value.is_valid_float():
					return _fail("Ungültige Zahl für --tolerance: " + value)
				tolerance = clampf(value.to_float(), 0.0, 1.0)
				i += 1
			"--crop":
				var parts := value.split(",")
				if parts.size() != 4 or Array(parts).any(func(p): return not p.strip_edges().is_valid_int()):
					return _fail("Ungültiger Ausschnitt für --crop: " + value + " (Format X,Y,B,H)")
				crop = Rect2i(parts[0].to_int(), parts[1].to_int(), parts[2].to_int(), parts[3].to_int())
				i += 1
			"--trim":
				trim = true
			"--fit", "--size":
				var dims := _parse_size(value)
				if dims == Vector2i.ZERO:
					return _fail("Ungültige Größe für %s: %s (Format BxH, z. B. 128x64)" % [option, value])
				if option == "--fit":
					fit = dims
				else:
					size = dims
				i += 1
			_:
				return _fail("Unbekannte Option: " + option)
		i += 1

	var img := Image.load_from_file(input)
	if img == null or img.is_empty():
		return _fail("Bild lässt sich nicht laden: " + input)
	img.convert(Image.FORMAT_RGBA8)

	if key != "":
		_key_out(img, Color.html(key), tolerance)
	if crop.size != Vector2i.ZERO:
		var inside := crop.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		if inside.size.x <= 0 or inside.size.y <= 0:
			return _fail("Der Ausschnitt liegt außerhalb des Bildes (%dx%d)." % [img.get_width(), img.get_height()])
		img = img.get_region(inside)
	if trim:
		var used := img.get_used_rect()
		if used.size.x == 0 or used.size.y == 0:
			return _fail("Nach dem Freistellen ist nichts mehr übrig (Schlüsselfarbe oder Toleranz prüfen).")
		img = img.get_region(used)
	if fit != Vector2i.ZERO:
		var scale := minf(float(fit.x) / img.get_width(), float(fit.y) / img.get_height())
		img.resize(maxi(1, roundi(img.get_width() * scale)), maxi(1, roundi(img.get_height() * scale)), Image.INTERPOLATE_LANCZOS)
	if size != Vector2i.ZERO:
		img.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)

	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var err := img.save_png(output)
	if err != OK:
		return _fail("Speichern fehlgeschlagen (%s): %s" % [error_string(err), output])
	print("BILD: ok %dx%d %s" % [img.get_width(), img.get_height(), output])
	return 0


## Macht Pixel nahe der Schlüsselfarbe transparent, mit weicher Kante bis zum doppelten Abstand.
func _key_out(img: Image, key: Color, tolerance: float) -> void:
	var soft := maxf(tolerance * 2.0, tolerance + 0.001)
	var norm := sqrt(3.0)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			var d := Vector3(c.r - key.r, c.g - key.g, c.b - key.b).length() / norm
			if d <= tolerance:
				img.set_pixel(x, y, Color(c.r, c.g, c.b, 0.0))
			elif d < soft:
				img.set_pixel(x, y, Color(c.r, c.g, c.b, c.a * (d - tolerance) / (soft - tolerance)))


func _parse_size(text: String) -> Vector2i:
	var parts := text.to_lower().split("x")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return Vector2i.ZERO
	var dims := Vector2i(parts[0].to_int(), parts[1].to_int())
	return dims if dims.x > 0 and dims.y > 0 else Vector2i.ZERO


func _fail(message: String) -> int:
	printerr("BILD: FEHLER " + message)
	print("BILD: FEHLER " + message)
	return 1
