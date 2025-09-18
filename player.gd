extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 650.0
const JUMP_VELOCITY = -1050.0
const CLIMB_SPEED = 300.0
const MAX_SPEED = 300.0
const ACCELERATION = 50.0
const FRICTION = 30.0

# Made gravity a bit stronger
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.9
var is_falling = false
var on_ladder: bool = false
var spawn_position: Vector2 

func movement(delta: float) -> void:
	var grounded = is_on_floor()
	# Add the gravity.

	if not grounded:
		velocity.y += gravity * delta
	else:
		animated_sprite.offset.y = 0	
		is_falling = false
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			animated_sprite.play("walk")
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handles animations	
	if velocity.x == 0 and velocity.y == 0:
		animated_sprite.play("idle")
	# If walking left
	if direction == -1:
		animated_sprite.flip_h = true
		animated_sprite.offset.x = -16
	
	if direction == 1:
		animated_sprite.offset.x = 0
		animated_sprite.flip_h = false

	if not is_on_floor() and is_falling == false:
		animated_sprite.play("fall")
		animated_sprite.offset.y = 5
		is_falling = true
		
	if global_position.y > 1000:
		respawn()
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY	
		animated_sprite.play("jump")
		is_falling = false
		
	if Input.is_action_just_pressed("down") and is_on_floor():
		position.y += 5
	
func _ladder_detect():
	if $ladder_detect_ray.is_colliding() and !is_on_floor():
		if Input.is_action_pressed("climb") or Input.is_action_pressed("down"):
			on_ladder = true
			
		var desired_x_pos: float = $ladder_detect_ray.get_collider().get_child($ladder_detect_ray.get_collider_shape()).global_position.x + 30
		if global_position.x != desired_x_pos:
			var x_pos_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
			x_pos_tween.tween_property(self, "global_position:x", desired_x_pos, 0.05)
	else:
		on_ladder = false
	
func ladder_movement(delta: float) -> void:
	var y_input: float = Input.get_axis("climb", "down")
	var velocity_weight: float = delta * (ACCELERATION if y_input else FRICTION)
	velocity.y = lerp(velocity.y, y_input * MAX_SPEED, velocity_weight)
	if velocity.y == 0:
		animated_sprite.pause()
	velocity.x = 0.0
	
func _ready() -> void:
	var spawn_point = get_tree().get_first_node_in_group("spawn") 
	if spawn_point:
		spawn_position = spawn_point.global_position
	else:
		spawn_position = global_position 
		
func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO  # reset momentum 
			
func _physics_process(delta: float) -> void:
	_ladder_detect()
	if on_ladder:
		animated_sprite.play("climb")
		ladder_movement(delta)
	else:
		movement(delta)
	
	move_and_slide()
