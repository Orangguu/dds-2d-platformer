extends Node2D

@export var force = -1500.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y = force
