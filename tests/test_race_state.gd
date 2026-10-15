extends "res://tests/base_test.gd"

var race: RaceState

func setup() -> void:
	race = RaceState.new()


func test_start_im_countdown() -> void:
	check_eq(race.phase, RaceState.Phase.COUNTDOWN, "phase ist COUNTDOWN")
	check(not race.can_drive(), "can_drive() ist falsch am Start")
	check_eq(race.countdown_text(), "3", "countdown_text() ist '3' am Start")


func test_countdown_text() -> void:
	race.update(0.5)
	check_eq(race.countdown_text(), "3", "countdown_text() ist noch '3' nach 0.5s")

	race.update(1.0)
	check_eq(race.countdown_text(), "2", "countdown_text() ist '2' nach insgesamt 1.5s")

	race.update(1.0)
	check_eq(race.countdown_text(), "1", "countdown_text() ist '1' nach insgesamt 2.5s")


func test_countdown_endet() -> void:
	race.update(1.0)
	race.update(1.0)
	race.update(1.0)

	check_eq(race.phase, RaceState.Phase.RACING, "phase ist RACING nach Countdown")
	check(race.can_drive(), "can_drive() ist wahr nach Countdown")
	check_eq(race.countdown, 0.0, "countdown ist 0.0 nach Ablauf")
	check_eq(race.countdown_text(), "Los!", "countdown_text() ist 'Los!' nach Countdown")


func test_los_verschwindet() -> void:
	race.update(3.0)
	race.update(1.5)

	check_eq(race.countdown_text(), "", "countdown_text() ist leer nach 1.5s Fahrtzeit")
	check_eq(race.race_time, 1.5, "race_time ist 1.5")


func test_runde_im_countdown_zaehlt_nicht() -> void:
	# Ohne vorheriges update sind wir noch im Countdown
	race.on_lap(10.0)

	check_eq(race.lap_times.size(), 0, "lap_times hat keine Einträge im Countdown")


func test_drei_runden_beenden_rennen() -> void:
	race.update(3.0)
	race.on_lap(30.0)
	race.on_lap(28.5)

	check_eq(race.phase, RaceState.Phase.RACING, "phase ist noch RACING nach 2 Runden")

	race.on_lap(29.0)

	check_eq(race.phase, RaceState.Phase.FINISHED, "phase ist FINISHED nach 3 Runden")
	check(not race.can_drive(), "can_drive() ist falsch nach Ziel")
	check_eq(race.best_lap(), 28.5, "best_lap() ist 28.5")


func test_nach_ziel_keine_zeit_mehr() -> void:
	race.update(3.0)
	race.update(10.0)
	race.on_lap(5.0)
	race.on_lap(5.0)
	race.on_lap(5.0)
	race.update(7.0)

	check_eq(race.race_time, 10.0, "race_time bleibt bei 10.0 nach Ziel")
	check_eq(race.lap_times.size(), 3, "lap_times hat genau 3 Einträge")


func test_ergebnistext() -> void:
	race.update(3.0)
	race.update(87.5)
	race.on_lap(30.0)
	race.on_lap(28.5)
	race.on_lap(29.0)

	var expected = "Ziel!\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nEnter: neues Rennen"
	check_eq(race.result_text(1234), expected, "result_text() stimmt")


func test_reset() -> void:
	race.update(3.0)
	race.on_lap(30.0)
	race.reset()

	check_eq(race.phase, RaceState.Phase.COUNTDOWN, "phase ist COUNTDOWN nach reset")
	check_eq(race.countdown, 3.0, "countdown ist 3.0 nach reset")
	check_eq(race.race_time, 0.0, "race_time ist 0.0 nach reset")
	check_eq(race.lap_times.size(), 0, "lap_times.size() ist 0 nach reset")
	check_eq(race.best_lap(), -1.0, "best_lap() ist -1.0 nach reset")
