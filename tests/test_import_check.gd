extends "res://tests/base_test.gd"

func test_arten() -> void:
	check_eq(ImportCheck.kind_of("assets/Held.PNG"), "bild", "PNG-Endung zu bild")
	check_eq(ImportCheck.kind_of("musik.ogg"), "audio", "OGG-Endung zu audio")
	check_eq(ImportCheck.kind_of("level.glb"), "3d", "GLB-Endung zu 3d")
	check_eq(ImportCheck.kind_of("text.txt"), "", "Unbekannte Endung ergibt leer")


func test_pruefen() -> void:
	var r := ImportCheck.check("a.txt", 10)
	check(r.code == "incompatible", "Unbekanntes Format führt zu incompatible")

	r = ImportCheck.check("a.png", 0)
	check(r.code == "invalid_argument", "Leere Datei führt zu invalid_argument")

	r = ImportCheck.check("a.png", 100)
	check(r.is_ok(), "Gültige PNG-Datei ist ok")
	check_eq(r.data.kind, "bild", "Art bei PNG korrekt")
	check_eq(r.data.extension, "png", "Extension bei PNG korrekt")


func test_kopf() -> void:
	var head := PackedByteArray([0x89, 0x50, 0x4E, 0x47, 0x0D])
	check(ImportCheck.header_ok("a.png", head), "PNG-Kopf korrekt erkannt")

	head = PackedByteArray([0, 1, 2, 3])
	check(not ImportCheck.header_ok("a.png", head), "Falscher PNG-Kopf führt zu false")

	head = PackedByteArray([0x89])
	check(not ImportCheck.header_ok("a.png", head), "Zu kurzer Kopf führt zu false")

	head = PackedByteArray()
	check(ImportCheck.header_ok("a.obj", head), "Unbekannte Endung mit kleinem Kopf erlaubt (true)")


func test_liste() -> void:
	var text := ImportCheck.supported_text()
	check_eq(text, "Bild: jpeg, jpg, png, webp; Audio: mp3, ogg, wav; 3D: glb, gltf, obj", "Unterstützte Formate korrekt gruppiert")
