class_name PhysicsWorld2D
extends RefCounted

## Ein 2D-Physiksystem, das mehrere dynamische Körper gegen statische Hindernisse prüft.
## Kollisionsebenen werden beachtet und Kontakte werden gemeldet.

var bodies: Dictionary = {}
## Schlüssel: Kennung (String)
## Wert: {"body": Body2D, "layer": int, "mask": int}

var statics: Array[Dictionary] = []
## Jeder Eintrag: {"id": String, "rect": Rect2, "layer": int, "mask": int}

var contacts: Array[Dictionary] = []
## Alle gemeldeten Kontakte in Reihenfolge ihres Entstehens.
## Jeder Kontakt: {"step": int, "body": String, "static": String}

var step_count := 0
## Anzahl der ausgeführten Schritt-Zyklen

var floor_y := 1000.0
## Y-Position des Bodens


func add_body(id: String, body: Body2D, layer: int = 1, mask: int = 1) -> void:
	"""Einen dynamischen Körper zur Welt hinzufügen."""
	bodies[id] = {"body": body, "layer": layer, "mask": mask}


func add_static(id: String, rect: Rect2, layer: int = 1, mask: int = 1) -> void:
	"""Ein statisches Hindernis (Rechteck) zur Welt hinzufügen."""
	statics.append({"id": id, "rect": rect, "layer": layer, "mask": mask})


func step(dt: float) -> Array[Dictionary]:
	"""Einen Physikschritt durchführen und Kontakte zurückgeben."""
	step_count += 1
	var contacts_this_step: Array[Dictionary] = []

	# Körper in sortierter Reihenfolge (Kennungen alphabetisch)
	var ids: Array[String] = []
	for key in bodies:
		ids.append(key)
	ids.sort()

	for id in ids:
		var entry: Dictionary = bodies[id]
		var body: Body2D = entry["body"]
		var layer: int = entry["layer"]
		var mask: int = entry["mask"]

		# Alte Position merken
		var old_position: Vector2 = body.position

		# Körper physikalisch aktualisieren
		body.step(dt, floor_y)

		# Jedes Hindernis in Reihenfolge prüfen
		for s in statics:
			if s.rect.has_point(body.position):
				# Kollisionsmasken prüfen
				if CollisionLayers.collides(layer, mask, s.layer, s.mask):
					# Körper auf alte Position zurücksetzen
					body.position = old_position
					body.velocity = Vector2.ZERO

					# Kontakt melden
					var contact: Dictionary = {"step": step_count, "body": id, "static": s.id}
					contacts_this_step.append(contact)
					contacts.append(contact)
					# Kein weiteres Hindernis für diesen Körper prüfen
					break

	return contacts_this_step


func run(seconds: float, hz: int = 120) -> int:
	"""Eine bestimmte Anzahl an Schritten durchführen.

	Zurückgegeben wird die Anzahl aller Kontakte in dieser Zeit.
	"""
	var steps: int = roundi(seconds * hz)
	for i in range(steps):
		step(1.0 / hz)
	return contacts.size()
