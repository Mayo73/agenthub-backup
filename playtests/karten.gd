extends Playtest
## Spieltest: Profilkarten mehrerer Testpersonen nacheinander zeigen (Material für Design-Prüfungen).
## Überspringt Profile mit dem Knopf, prüft, dass jede Karte ein anderes Profil zeigt, und macht je ein Bild.

const STORE := "user://spieltest_karten.json"
const CARDS := 4


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Profilkarten mehrerer Testpersonen nacheinander"


func run() -> void:
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
	scene.use_store(STORE)
	await wait(0.3)

	var seen: Array[String] = []
	for i in CARDS:
		var d := scene.screen as DiscoverScreen
		check(d != null, "Entdecken ist offen")
		if d == null:
			return
		var p := d.card.profile
		check(p != null, "Karte %d zeigt ein Profil" % (i + 1))
		if p == null:
			return
		check(not seen.has(p.id), "Karte %d zeigt ein neues Profil" % (i + 1))
		seen.append(p.id)
		check(d.card.avatar.shade, "Porträt mit dunklem Verlauf unten")
		shot("karte-%d" % (i + 1))
		await wait(0.3)
		d.pass_button.pressed.emit()
		await wait(0.3)
	measure("karten", seen.size())

	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	check(scene.tab_buttons["matches"].disabled, "Reiter Matches ist aktiv")
	shot("matches")
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
