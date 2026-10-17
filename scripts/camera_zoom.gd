class_name CameraZoom
extends RefCounted
## Zoom der Kamera passend zur Zellgröße: doppelter Radius = halber Zoom.
## Die Spielerzelle erscheint so immer etwa 31 Pixel groß im Radius (bei 1920 × 1080).

const BASE_RADIUS := 12.0
const BASE_ZOOM := 2.6
const MIN_ZOOM := 0.3
const MAX_ZOOM := 4.0


static func target_for_radius(radius: float) -> float:
	return clampf(BASE_ZOOM * BASE_RADIUS / radius, MIN_ZOOM, MAX_ZOOM)


## Gleitet von current Richtung target, unabhängig von der Bildrate.
static func smooth(current: float, target: float, delta: float, rate: float = 2.0) -> float:
	return lerpf(current, target, 1.0 - exp(-rate * delta))
