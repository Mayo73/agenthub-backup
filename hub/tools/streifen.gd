# Setzt mehrere Bilder zu einem Bildstreifen zusammen: Raster in Lesereihenfolge (links oben nach
# rechts unten), damit man Bewegung (Rauch, Wolken, Blitze, Animationen) auf einem Bild sieht.
#   "<godot>" --headless --script C:/Users/wiens/AgentHub/hub/tools/streifen.gd -- <ausgabe.png> <spalten> <bildbreite> <bild1> <bild2> ...
# Ausgabe: "STREIFEN: ok <breite>x<höhe> <ausgabe>" (Exit-Code 0) oder "STREIFEN: FEHLER …" (Exit-Code 1).
extends SceneTree

const GAP := 6
const BACKGROUND := Color(0.08, 0.08, 0.1)


func _init() -> void:
	quit(_run(OS.get_cmdline_user_args()))


func _run(args: PackedStringArray) -> int:
	if args.size() < 4 or not args[1].is_valid_int() or not args[2].is_valid_int():
		return _fail("Aufruf: streifen.gd -- <ausgabe.png> <spalten> <bildbreite> <bild1> <bild2> ...")
	var output := args[0].replace("\\", "/")
	var columns := maxi(1, args[1].to_int())
	var cell_width := maxi(16, args[2].to_int())
	var images: Array[Image] = []
	for i in range(3, args.size()):
		var img := Image.load_from_file(args[i].replace("\\", "/"))
		if img == null or img.is_empty():
			return _fail("Bild lässt sich nicht laden: " + args[i])
		img.convert(Image.FORMAT_RGBA8)
		var cell_height := maxi(1, roundi(float(img.get_height()) * cell_width / img.get_width()))
		img.resize(cell_width, cell_height, Image.INTERPOLATE_LANCZOS)
		images.append(img)
	var cell_h := images[0].get_height()
	var rows := ceili(float(images.size()) / columns)
	var cols := mini(columns, images.size())
	var canvas := Image.create(cols * cell_width + (cols + 1) * GAP, rows * cell_h + (rows + 1) * GAP, false, Image.FORMAT_RGBA8)
	canvas.fill(BACKGROUND)
	for i in images.size():
		var x := GAP + (i % columns) * (cell_width + GAP)
		var y := GAP + (i / columns) * (cell_h + GAP)
		canvas.blit_rect(images[i], Rect2i(Vector2i.ZERO, images[i].get_size()), Vector2i(x, y))
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var err := canvas.save_png(output)
	if err != OK:
		return _fail("Speichern fehlgeschlagen (%s): %s" % [error_string(err), output])
	print("STREIFEN: ok %dx%d %s" % [canvas.get_width(), canvas.get_height(), output])
	return 0


func _fail(message: String) -> int:
	print("STREIFEN: FEHLER " + message)
	return 1
