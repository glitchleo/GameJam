extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var Jump_Buffer:bool = false
# Pulls the default gravity setting directly from your Godot Project Settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var coyote_timer = $CoyoteTimer

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	# If the player is in the air, pull them down over time
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Handle Jump
	# ui_accept is usually mapped to Spacebar / Enter
	if Input.is_action_just_pressed("jump") and (is_on_floor() or !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY

	# 3. Handle Left-Right Movement
	# ui_left and ui_right are your arrow keys or A/D keys
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# Brings the character to a smooth stop when you let go of the keys

	var was_on_floor = is_on_floor()
	
	# 4. Execute Movement
	# This built-in function calculates the velocity and handles all wall/floor collisions
	move_and_slide()
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
