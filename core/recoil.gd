class_name Recoil
extends RefCounted

## Waffenrückstoß in 3D.
## Jeder Schuss hebt die Waffe an (pitch), danach kehrt sie gleichmäßig zurück.
## Maßeinheit: Grad, max_pitch begrenzt den maximalen Rückstoß.

var kick: float = 2.0 ## Grad pro Schuss
var recovery: float = 10.0 ## Grad pro Sekunde (Erholungsrate)
var max_pitch: float = 10.0 ## Maximaler Pitch in Grad
var pitch: float = 0.0 ## Aktueller Pitch in Grad

func _init(kick_deg: float = 2.0, recovery_deg: float = 10.0, max_deg: float = 10.0) -> void:
	kick = kick_deg
	recovery = recovery_deg
	max_pitch = max_deg

func fire() -> void:
	pitch = minf(pitch + kick, max_pitch)

func step(dt: float) -> float:
	pitch = maxf(pitch - recovery * dt, 0.0)
	return pitch

func reset() -> void:
	pitch = 0.0
