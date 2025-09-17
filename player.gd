extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 650.0
const JUMP_VELOCITY = -1050.0
const CLIMB_SPEED = 300.0

# Made gravity a bit stronger
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.9
var is_falling = false
var on_ladder: bool
var climbing: bool


func _on_area_2d_body_entered(body: Node2D) -> void:
	on_ladder = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	on_ladder = false
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	var grounded = is_on_floor()
	# Add the gravity.
	if on_ladder:
		var vertical_dir = Input.get_axis("climb","down")
		if vertical_dir:
			velocity.y = vertical_dir * CLIMB_SPEED
			climbing = not grounded
		else:
			velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED)
			if grounded: climbing = false
		if climbing:
			if vertical_dir: animated_sprite.play("climb")
			else: animated_sprite.pause()
			
	elif not grounded:
		velocity.y += gravity * delta
	else:
		animated_sprite.offset.y = 0	
		is_falling = false
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction and not climbing:
		velocity.x = direction * SPEED
		if is_on_floor():
			animated_sprite.play("walk")
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handles animations	
	if not climbing:
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
		
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY	
		animated_sprite.play("jump")
		is_falling = false
		
	if Input.is_action_just_pressed("down") and is_on_floor():
		position.y += 5
	move_and_slide()
