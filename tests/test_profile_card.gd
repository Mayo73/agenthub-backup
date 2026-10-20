extends "res://tests/base_test.gd"

var card: ProfileCard


func setup() -> void:
	card = ProfileCard.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(card)


func teardown() -> void:
	card.free()


func test_testprofil_hinweis() -> void:
	check(card.demo_tag.text.contains("TESTPROFIL"), "Demo-Tag enthält TESTPROFIL")


func test_texte() -> void:
	var profiles := DemoData.profiles()
	var sam := profiles[1]  # Sam, 33, MMA, Erfahren, 7 Jahre

	card.set_profile(sam)

	check(card.name_label.text == "Sam, 33", "name_label zeigt 'Sam, 33'")
	check(card.art_label.text == "MMA", "art_label zeigt 'MMA'")
	check(card.level_label.text == "Erfahren · 7 Jahre Training", "level_label zeigt 'Erfahren · 7 Jahre Training'")
	check(card.bio_label.text == sam.bio, "bio_label zeigt Bio von Sam")


func test_ein_jahr() -> void:
	var profiles := DemoData.profiles()
	var jonas := profiles[3]  # Jonas, 22, Kickboxen, Einsteiger, 1 Jahr

	card.set_profile(jonas)

	check(card.level_label.text == "Einsteiger · 1 Jahr Training", "level_label zeigt 'Einsteiger · 1 Jahr Training' bei 1 Jahr")


func test_avatar() -> void:
	var profiles := DemoData.profiles()
	var sam := profiles[1]

	card.set_profile(sam)
	check(card.avatar.profile == sam, "avatar.profile ist das gesetzte Profil")


func test_merkmale_sam() -> void:
	var profiles := DemoData.profiles()
	var sam := profiles[1]  # Sam, 33, MMA, Erfahren, 7 Jahre

	card.set_profile(sam)

	check(card.facts_label.text == "Gewicht: Schwer (über 84 kg)\nVerfügbar: Mo, Mi, Fr\nAusrüstung: Handschuhe, Schienbeinschoner, Mundschutz", "facts_label zeigt Gewicht, Verfügbarkeit und Ausrüstung für Sam")


func test_merkmale_jonas() -> void:
	var profiles := DemoData.profiles()
	var jonas := profiles[3]  # Jonas, 22, Kickboxen, Einsteiger, 1 Jahr

	card.set_profile(jonas)

	check(card.facts_label.text.ends_with("Ausrüstung: keine eigene"), "facts_label endet mit 'Ausrüstung: keine eigene' für Jonas")


func test_merkmale_reihenfolge() -> void:
	var profiles := DemoData.profiles()
	var sam := profiles[1]

	card.set_profile(sam)

	check(card.facts_label.get_index() > card.bio_label.get_index(), "facts_label kommt nach bio_label in der VBoxContainer")

func test_stempel_anfangs_unsichtbar() -> void:
	check(not card.like_stamp.visible, "SPARRING-Stempel anfangs unsichtbar")
	check(not card.pass_stamp.visible, "NEIN-Stempel anfangs unsichtbar")
	check_eq((card.like_stamp.get_child(0) as Label).text, "SPARRING", "Text des Ja-Stempels")
	check_eq((card.pass_stamp.get_child(0) as Label).text, "NEIN", "Text des Nein-Stempels")
	check(card.get_child(card.get_child_count() - 1) == card.stamp_layer, "Stempel liegen zuoberst")


func test_stempel_zeigen() -> void:
	card.show_stamp(SwipeGesture.Result.LIKE, 0.6)
	check(card.like_stamp.visible, "LIKE zeigt den Ja-Stempel")
	check(is_equal_approx(card.like_stamp.modulate.a, 0.6), "Deckkraft folgt der Stärke")
	check(not card.pass_stamp.visible, "LIKE versteckt den Nein-Stempel")
	card.show_stamp(SwipeGesture.Result.PASS, 1.0)
	check(card.pass_stamp.visible, "PASS zeigt den Nein-Stempel")
	check(not card.like_stamp.visible, "PASS versteckt den Ja-Stempel")
	card.show_stamp(SwipeGesture.Result.NONE, 0.0)
	check(not card.like_stamp.visible and not card.pass_stamp.visible, "NONE versteckt beide")