extends "res://tests/base_test.gd"

var fc: FireControl


func setup() -> void:
	pass


func test_abstand() -> void:
	fc = FireControl.new(4.0, 6, 1.5)

	# Erster Schuss sollte erfolgreich sein
	var first_shot: bool = fc.fire()
	check(first_shot, "erster Schuss erfolgreich")

	# Sofort nochmal feuern sollte nicht gehen (Cooldown)
	var second_shot: bool = fc.fire()
	check(not second_shot, "sofort nachladen verboten durch Cooldown")

	# Nach 0.25s sollte Cooldown vorbei sein und Feuer erlaubt
	fc.step(0.25)
	var third_shot: bool = fc.fire()
	check(third_shot, "nach 0.25s wieder feuerbereit")


func test_magazin_leer() -> void:
	fc = FireControl.new(100.0, 2, 1.0)

	# Ersten Schuss abfeuern
	var first: bool = fc.fire()
	check(first, "erster Schuss erfolgreich")

	# Kurz warten und zweiten Schuss abfeuern
	fc.step(0.02)
	var second: bool = fc.fire()
	check(second, "zweiter Schuss erfolgreich")

	# Jetzt sollte Magazin leer sein
	check(fc.ammo == 0, "Munition auf 0 reduziert")
	check(fc.is_reloading(), "automatisch beim Nachladen")

	# Weiteres Feuern sollte nicht gehen
	var extra: bool = fc.fire()
	check(not extra, "kein Feuer wenn Magazine bei 0")


func test_nachladen() -> void:
	fc = FireControl.new(100.0, 2, 1.0)

	# Beide Schüsse abfeuern
	fc.fire()
	fc.step(0.02)
	fc.fire()

	check(fc.ammo == 0, "Munition auf 0")
	check(fc.is_reloading(), "wird nachgeladen")

	# Warten bis Nachladen fertig ist
	fc.step(1.0)

	check(fc.ammo == 2, "Munition wieder voll (2)")
	check(not fc.is_reloading(), "nicht mehr beim Nachladen")


func test_voll_kein_nachladen() -> void:
	fc = FireControl.new(4.0, 6, 1.5)

	# Sofortiges Nachladen bei vollem Magazin sollte nicht gehen
	var result: bool = fc.reload()
	check(not result, "kein Nachladen bei vollem Magazin")


func test_schuesse_pro_sekunde() -> void:
	fc = FireControl.new(4.0, 100, 1.0)

	# Über 2 Sekunden sollten bei 4 Schüssen/Sekunde genau 8 Schüsse möglich sein
	var shots: int = fc.shots_in(2.0)
	check_eq(shots, 8, "8 Schüsse in 2 Sekunden bei 4 Schuss/Sekunde")
