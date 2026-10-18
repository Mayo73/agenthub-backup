extends "res://tests/base_test.gd"

var book: MatchBook

func setup() -> void:
	book = MatchBook.new()


func test_einseitig_kein_match() -> void:
	var result := book.like("p01", "p02")
	check_eq(result, "", "like soll leeren String zurückgeben")
	check(book.matches.size() == 0, "keine Matches vorhanden")
	check(book.match_between("p01", "p02").is_empty(), "match_between soll leeres Dictionary zurückgeben")


func test_gegenseitig_match() -> void:
	var r1 := book.like("p01", "p02")
	check_eq(r1, "", "erstes Like gibt kein Match zurück")
	var r2 := book.like("p02", "p01")
	check_eq(r2, "m1", "gegenseitiges Like erzeugt Match mit ID m1")
	var m := book.match_between("p02", "p01")
	check_eq(m["id"], "m1", "Match-ID stimmt überein")
	check_eq(m["a"], "p01", "a ist der erste Likende (p01)")
	check_eq(m["b"], "p02", "b ist der zweite Likende (p02)")


func test_kein_doppeltes_match() -> void:
	book.like("p01", "p02")
	book.like("p02", "p01")
	var count := book.matches.size()

	var r3 := book.like("p02", "p01")
	var r4 := book.like("p01", "p02")
	check_eq(r3, "", "zweites Like nach bestehendem Match soll '' zurückgeben")
	check_eq(r4, "", "drittes Like nach bestehendem Match soll '' zurückgeben")
	check(book.matches.size() == count, "genau 1 Match vorhanden (kein doppeltes)")


func test_verschiedene_sportarten() -> void:
	# Verschiedene Kampfsportarten spielen keine Rolle für Matches
	book.like("p01", "p02")
	var result := book.like("p02", "p01")
	check(result != "", "Match zwischen verschiedenen Sportarten entsteht")
	check(not book.match_between("p01", "p02").is_empty(), "Match ist auffindbar")


func test_selbst_liken() -> void:
	var result := book.like("p01", "p01")
	check_eq(result, "", "Selbstlike gibt leeren String zurück")
	check(book.likes.is_empty(), "likes Dictionary soll leer bleiben")


func test_kandidaten() -> void:
	var all: Array[String] = ["p01", "p02", "p03", "p04"]

	book.like("p01", "p02")
	book.pass_on("p01", "p03")

	var c1 := book.candidates("p01", all)
	check_eq(c1, ["p04"], "Kandidaten für p01 sind [p04]")

	var c2 := book.candidates("p02", all)
	check_eq(c2, ["p01", "p03", "p04"], "Kandidaten für p02 sind [p01,p03,p04]")


func test_match_beenden() -> void:
	book.like("p01", "p02")
	book.like("p02", "p01")

	var m1_id: String = book.matches[0]["id"]
	check(book.is_active(m1_id), "Match ist anfangs aktiv")

	# Unbeteiligter kann Match nicht beenden
	book.end_match(m1_id, "p03")
	check(book.is_active(m1_id), "unbeteiligter p03 ändert nichts")

	# Teilnehmer beendet das Match
	book.end_match(m1_id, "p02")
	check(not book.is_active(m1_id), "Match nicht mehr aktiv nach Beendung")
	var m := book.get_match(m1_id)
	check_eq(m["ended_by"], "p02", "ended_by ist p02")

	# Match bleibt in matches_of enthalten
	check(book.matches_of("p01").size() == 1, "Match bleibt in matches_of von p01 enthalten")


func test_blockieren() -> void:
	book.like("p01", "p02")
	book.like("p02", "p01")

	var m1_id: String = book.matches[0]["id"]

	book.block("p01", "p02")

	check(book.is_blocked("p02", "p01"), "is_blocked nach block() wahr")
	check(not book.is_active(m1_id), "Match nach Blockierung inaktiv")

	var result := book.like("p02", "p01")
	check_eq(result, "", "like nach Block gibt '' zurück")

	var c := book.candidates("p02", ["p01", "p03"])
	check_eq(c, ["p03"], "p01 wird nicht in Kandidaten von p02 enthalten sein")


func test_andere_person() -> void:
	var m := {"a": "p01", "b": "p02"}

	check(book.other(m, "p01") == "p02", "andere Person von p01 ist p02")
	check(book.other(m, "p02") == "p01", "andere Person von p02 ist p01")


func test_speichern_laden() -> void:
	# Likes, Pass und Match anlegen
	book.like("p01", "p02")
	var m1_id: String = book.like("p02", "p01")
	check(m1_id != "", "Match-Id erhalten")
	book.pass_on("p01", "p03")
	book.block("p01", "p04")

	var dict := book.to_dict()
	var loaded := MatchBook.from_dict(dict)

	check_eq(loaded.likes, dict["likes"], "likes gleich")
	check_eq(loaded.passes, dict["passes"], "passes gleich")
	check_eq(loaded.blocks, dict["blocks"], "blocks gleich")
	check_eq(loaded.matches.size(), dict["matches"].size(), "gleiche Matchanzahl")
	check_eq(loaded.next_id, book.next_id, "next_id gleich")

	# Neues Match im geladenen Buch bekommt nächste ID
	loaded.like("p03", "p04")
	var new_match_id: String = loaded.like("p04", "p03")
	check_eq(new_match_id, "m2", "neues Match bekommt m2")
