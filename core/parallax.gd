class_name Parallax
extends RefCounted

## Parallax-Effekt für Hintergrundebenen mit Tiefenwirkung.
## Nur statische Funktionen, da keine Instanzzustände benötigt werden.


## Berechnet den Scroll-Offset basierend auf Kamera und Depth-Faktor.
## @param camera: Kamera-Position in Weltkoordinaten
## @param factor: Tiefenfaktor pro Achse (kleinere Werte = weiter hinten)
## @return: Offset-Vektor für die Parallax-Ebene
static func scroll(camera: Vector2, factor: Vector2) -> Vector2:
	return Vector2(-camera.x * factor.x, -camera.y * factor.y)


## Wrappt eine X-Position nahtlos innerhalb einer Breite.
## Wird verwendet, um Hintergrundbildern ein endloses Muster zu geben.
## @param x: Aktuelle X-Position
## @param width: Breite des wiederholenden Elements
## @return: Eingewickelte Position im Bereich [0, width)
static func wrap(x: float, width: float) -> float:
	if width <= 0.0:
		return x
	return fposmod(x, width)


## Berechnet die Anzahl der Kacheln, die benötigt werden, um eine Ansicht
## mit einer bestimmten Breite nahtlos abzudecken.
## @param view_width: Breite des sichtbaren Bereichs
## @param tile_width: Breite einer einzelnen Kachel
## @return: Anzahl benötigter Kacheln (mindestens 1 bei gültigen Werten)
static func tiles_needed(view_width: float, tile_width: float) -> int:
	if tile_width <= 0.0:
		return 0
	return ceili(view_width / tile_width) + 1
