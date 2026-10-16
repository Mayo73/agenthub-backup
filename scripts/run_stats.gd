class_name RunStats
extends RefCounted
## Zahlen eines Durchlaufs für den Rückblick am Ende der Zellenphase.


var play_time := 0.0
var food_eaten := 0
var cells_defeated := 0
var deaths := 0
var editor_visits := 0
var diet_history: Array[String] = []  ## Ernährung beim Erreichen jedes Größenabschnitts


## Erhöht play_time um delta.
func tick(delta: float) -> void:
	play_time += delta


## Hängt diet an diet_history an.
func record_stage(diet: String) -> void:
	diet_history.append(diet)


## Spielzeit als "M:SS", z. B. 125 Sekunden → "2:05".
func time_text() -> String:
	var minutes := floori(play_time / 60.0)
	var seconds := int(play_time) % 60
	return "%d:%02d" % [minutes, seconds]


## Häufigster Eintrag in diet_history; bei Gleichstand gewinnt der zuletzt gleichgezogene.
func main_diet() -> String:
	if diet_history.is_empty():
		return ""
	var counts: Dictionary = {}
	var best_diet := ""
	var best_count := 0
	for entry in diet_history:
		counts[entry] = counts.get(entry, 0) + 1
		if counts[entry] >= best_count:
			best_count = counts[entry]
			best_diet = entry
	return best_diet


## Fünf Zeilen für den Rückblick.
func summary_lines() -> Array[String]:
	return [
		"Spielzeit: %s" % time_text(),
		"Nahrung gefressen: %d" % food_eaten,
		"Zellen besiegt: %d" % cells_defeated,
		"Gestorben: %d" % deaths,
		"Editorbesuche: %d" % editor_visits
	]


## Für das Speichern im Spielstand.
func to_dict() -> Dictionary:
	return {
		"play_time": play_time,
		"food_eaten": food_eaten,
		"cells_defeated": cells_defeated,
		"deaths": deaths,
		"editor_visits": editor_visits,
		"diet_history": diet_history.duplicate()
	}


## Liest RunStats aus einem gespeicherten Dictionary.
static func from_dict(d: Dictionary) -> RunStats:
	var s := RunStats.new()
	s.play_time = maxf(0.0, float(d.get("play_time", 0)))
	s.food_eaten = maxi(0, int(d.get("food_eaten", 0)))
	s.cells_defeated = maxi(0, int(d.get("cells_defeated", 0)))
	s.deaths = maxi(0, int(d.get("deaths", 0)))
	s.editor_visits = maxi(0, int(d.get("editor_visits", 0)))
	var history: Array = d.get("diet_history", [])
	for entry in history:
		s.diet_history.append(str(entry))
	return s
