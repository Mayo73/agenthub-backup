extends "res://tests/base_test.gd"

var s: EditorSession

func setup() -> void:
	s = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), PartUnlocks.new())


func test_gesperrt() -> void:
	check_eq(s.place("geissel", Vector2(-1, 0)), -1, "Gesperrte Geißel wird nicht gebaut")
	check_eq(s.cost(), 0, "Kosten bleiben 0 bei gesperrtem Teil")


func test_einbauen_kostet() -> void:
	var idx := s.place("kiefer", Vector2(0.9, 0.3))
	check_eq(idx, 2, "Kiefer wird an Index 2 eingebaut")
	check_eq(s.cost(), 10, "Ein Kiefer kostet 10 DNA")
	s.unlocks.unlock("geissel")
	idx = s.place("geissel", Vector2(-1, 0))
	check_eq(idx, 3, "Geißel wird an Index 3 eingebaut")
	check_eq(s.cost(), 25, "Kiefer + Geißel kosten 25 DNA")
	check_eq(s.original.parts.size(), 2, "Original bleibt unverändert mit 2 Teilen")


func test_bestaetigen() -> void:
	s.place("kiefer", Vector2(0.9, 0.3))
	s.unlocks.unlock("geissel")
	s.place("geissel", Vector2(-1, 0))
	var p := CellProgress.new()
	p.eat(20)
	check(s.confirm(p) == null, "Nicht genug DNA: Bestätigen schlägt fehl")
	check_eq(p.dna, 20, "DNA bleibt unverändert bei fehlgeschlagener Bestätigung")
	p.eat(10)
	check(s.confirm(p) == s.working, "Genug DNA: Bestätigen klappt")
	check_eq(p.dna, 5, "DNA wird nach Bestätigung verrechnet (20 + 10 - 25 = 5)")


func test_rueckerstattung() -> void:
	s.working.remove_part(1) # Knopfauge, 5 DNA
	check_eq(s.cost(), -5, "Entferntes Teil erstattet 5 DNA")
	var p := CellProgress.new()
	check(s.confirm(p) != null, "Rückerstattung wird bestätigt")
	check_eq(p.dna, 5, "Erstattete 5 DNA sind nun verfügbar")


func test_ohne_maul_ungueltig() -> void:
	s.working.remove_part(0) # Maul entfernen
	check(not s.is_valid(), "Ohne Maul ist Aufbau ungültig")
	check(not s.can_confirm(100), "Ungültiger Aufbau kann nicht bestätigt werden")


func test_abbrechen() -> void:
	s.place("kiefer", Vector2(0.9, 0.3))
	check(s.cancel() == s.original, "Abbrechen gibt Original zurück")
	check_eq(s.cancel().parts.size(), 2, "Original hat weiterhin 2 Teile")
