extends Area2D
## Sammelbare Münze. Meldet sich per Signal und verschwindet dann.

signal collected(value: int)

@export var value := 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit(value)
		queue_free()
