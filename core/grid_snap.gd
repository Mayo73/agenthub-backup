class_name GridSnap
extends RefCounted

## Einrasten von Position und Winkel auf ein Raster.
## Nur statische Funktionen.


## Rastet eine 2D-Position auf ein Raster mit der gegebenen Schrittweite ein.
static func snap(v: Vector2, step: float) -> Vector2:
	if step <= 0.0:
		return v
	return Vector2(
	round(v.x / step) * step,
	round(v.y / step) * step
	)


## Rastet eine 3D-Position auf ein Raster mit der gegebenen Schrittweite ein.
static func snap_3d(v: Vector3, step: float) -> Vector3:
	if step <= 0.0:
		return v
	return Vector3(
	round(v.x / step) * step,
	round(v.y / step) * step,
	round(v.z / step) * step
	)


## Rastet einen Winkel in Grad auf ein Raster mit der gegebenen Schrittweite ein.
## Das Ergebnis liegt immer im Bereich [0, 360).
static func snap_angle(deg: float, step_deg: float) -> float:
	if step_deg <= 0.0:
		return deg
	return fposmod(round(deg / step_deg) * step_deg, 360.0)
