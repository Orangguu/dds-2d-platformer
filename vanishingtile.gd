extends Node2D

@onready var timer: Timer = $VanishingTimer
@onready var reset_timer: Timer = $ResetTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		timer.start()

func _on_vanishing_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.4)
	collision_shape_2d.disabled = true
	
	reset_timer.start()
	

func _on_reset_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.4)
	collision_shape_2d.disabled = false 
