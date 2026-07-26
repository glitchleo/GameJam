extends CharacterBody2D

class_name PlatformerController2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var README: String = "IMPORTANT: MAKE SURE TO ASSIGN 'left' 'right' 'jump' 'up' 'down' 'run' in the project settings input map."

@export_category("Necessary Child Nodes")
@export var PlayerCollider: CollisionShape2D

# --- ADD THESE 3 LINES FOR THE SCORE ---
@export var scoreDisplay: Label 
@export var score_multiplier: float = 0.1 # 10 pixels climbed = 1 point
var starting_y: float = 0.0
var highest_reached_y: float = 0.0
var current_score: int = 0
# ---------------------------------------

#INFO HORIZONTAL MOVEMENT 
@export_category("L/R Movement")
@export_range(50, 500) var maxSpeed: float = 200.0
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.2
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.2
@export var directionalSnap: bool = false
@export var runningModifier: bool = false

#INFO JUMPING 
@export_category("Jumping and Gravity")
@export_range(0, 20) var jumpHeight: float = 2.0
@export_range(0, 4) var jumps: int = 1
@export_range(0, 100) var gravityScale: float = 20.0
@export_range(0, 1000) var terminalVelocity: float = 500.0
@export_range(0.5, 3) var descendingGravityFactor: float = 1.3
@export var shortHopAkaVariableJumpHeight: bool = true
@export_range(1, 10) var jumpVariable: float = 2
@export_range(0, 0.5) var coyoteTime: float = 0.2
@export_range(0, 0.5) var jumpBuffering: float = 0.2

@export_category("Corner Cutting/Jump Correct")
@export var cornerCutting: bool = false
@export_range(1, 5) var correctionAmount: float = 1.5
@export var leftRaycast: RayCast2D
@export var middleRaycast: RayCast2D
@export var rightRaycast: RayCast2D

@export_category("Survival & UI Mechanics")
## How much time the player starts with
@export var starting_oxygen: float = 30.0 
## Drag your new TimeDisplay Label here!
@export var timeDisplay: Label 

# Internal Variables
var current_oxygen: float
var appliedGravity: float
var maxSpeedLock: float
var appliedTerminalVelocity: float

var friction: float
var acceleration: float
var deceleration: float
var instantAccel: bool = false
var instantStop: bool = false

var jumpMagnitude: float = 500.0
var jumpCount: int

var jumpBufferCounter: float = 0.0
var coyoteCounter: float = 0.0

var gravityActive: bool = true
var wasMovingR: bool
var wasPressingR: bool
var movementInputMonitoring: Vector2 = Vector2(true, true)

var gdelta: float = 1
var dset = false
var col

# Input Variables
var leftHold
var leftTap
var rightHold
var rightTap
var jumpTap
var jumpRelease
var runHold

func _ready():
	wasMovingR = true
	col = PlayerCollider
	_updateData()
	
	# INFO Setup initial oxygen
	current_oxygen = starting_oxygen
	
	starting_y = global_position.y
	highest_reached_y = starting_y
	
func _updateData():
	acceleration = maxSpeed / timeToReachMaxSpeed
	deceleration = -maxSpeed / timeToReachZeroSpeed
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	maxSpeedLock = maxSpeed
	
	if timeToReachMaxSpeed == 0:
		instantAccel = true
		timeToReachMaxSpeed = 1
	elif timeToReachMaxSpeed < 0:
		timeToReachMaxSpeed = abs(timeToReachMaxSpeed)
		instantAccel = false
	else:
		instantAccel = false
		
	if timeToReachZeroSpeed == 0:
		instantStop = true
		timeToReachZeroSpeed = 1
	elif timeToReachMaxSpeed < 0:
		timeToReachMaxSpeed = abs(timeToReachMaxSpeed)
		instantStop = false
	else:
		instantStop = false
		
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
	
	coyoteTime = abs(coyoteTime)
	jumpBuffering = abs(jumpBuffering)
	
	if directionalSnap:
		instantAccel = true
		instantStop = true

func _process(delta):
	# INFO Survival Countdown Logic
	current_oxygen -= delta 
	
	# Update the Text UI (Formats to show 1 decimal place, e.g., 29.5s)
	if timeDisplay:
		# The "%.1f" formats the raw float down to one decimal place
		timeDisplay.text = "TIME: %.1f" % current_oxygen 
		
	# Check for Game Over
	if current_oxygen <= 0:
		print("Out of time! Game Over.")
		get_tree().reload_current_scene()
	# --- ADD THIS SCORE MATH ---
	# 1. Check if the player has reached a new height (remember, UP is negative Y!)
	if global_position.y < highest_reached_y:
		highest_reached_y = global_position.y
		
	# 2. Calculate the distance between where they started and their highest point
	var distance_climbed = starting_y - highest_reached_y
	
	# 3. Convert that pixel distance into a clean integer score
	current_score = int(distance_climbed * score_multiplier)
	
	# 4. Update the UI Text
	if scoreDisplay:
		scoreDisplay.text = "SCORE: " + str(current_score)

func _physics_process(delta):
	if !dset:
		gdelta = delta
		dset = true
		
	# Tick down our internal timers
	if jumpBufferCounter > 0:
		jumpBufferCounter -= delta
	if coyoteCounter > 0:
		coyoteCounter -= delta
		
	# Input Detection
	leftHold = Input.is_action_pressed("left")
	rightHold = Input.is_action_pressed("right")
	leftTap = Input.is_action_just_pressed("left")
	rightTap = Input.is_action_just_pressed("right")
	jumpTap = Input.is_action_pressed("jump")
	jumpRelease = Input.is_action_just_released("jump")
	
	# INFO Left and Right Movement
	if rightHold and leftHold and movementInputMonitoring:
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = -0.1
	elif rightHold and movementInputMonitoring.x:
		if velocity.x > maxSpeed or instantAccel:
			velocity.x = maxSpeed
		else:
			velocity.x += acceleration * delta
		if velocity.x < 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = -0.1
	elif leftHold and movementInputMonitoring.y:
		if velocity.x < -maxSpeed or instantAccel:
			velocity.x = -maxSpeed
		else:
			velocity.x -= acceleration * delta
		if velocity.x > 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0.1
				
	if velocity.x > 0:
		wasMovingR = true
	elif velocity.x < 0:
		wasMovingR = false
		
	if rightTap:
		wasPressingR = true
	if leftTap:
		wasPressingR = false
	
	if runningModifier and !runHold:
		maxSpeed = maxSpeedLock / 2
	elif is_on_floor(): 
		maxSpeed = maxSpeedLock
	
	if !(leftHold or rightHold):
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = 0
			
	# INFO Jump and Gravity
	if velocity.y > 0:
		appliedGravity = gravityScale * descendingGravityFactor
	else:
		appliedGravity = gravityScale
	
	appliedTerminalVelocity = terminalVelocity
	
	if gravityActive:
		if velocity.y < appliedTerminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > appliedTerminalVelocity:
				velocity.y = appliedTerminalVelocity
		
	if shortHopAkaVariableJumpHeight and jumpRelease and velocity.y < 0:
		velocity.y = velocity.y / jumpVariable
	
	# INFO Cleaned Up Jump Logic
	if is_on_floor():
		jumpCount = jumps
		coyoteCounter = coyoteTime 
		
	var wants_to_jump = jumpTap or (jumpBufferCounter > 0)
	
	if jumps == 1:
		if wants_to_jump and (is_on_floor() or coyoteCounter > 0):
			_jump()
			jumpBufferCounter = 0.0 
			coyoteCounter = 0.0     
	elif jumps > 1:
		if jumpTap and jumpCount > 0:
			_jump()
	
	# INFO Corner Cutting
	if cornerCutting:
		if velocity.y < 0 and leftRaycast and rightRaycast and middleRaycast:
			if leftRaycast.is_colliding() and !rightRaycast.is_colliding() and !middleRaycast.is_colliding():
				position.x += correctionAmount
			if !leftRaycast.is_colliding() and rightRaycast.is_colliding() and !middleRaycast.is_colliding():
				position.x -= correctionAmount
			
	move_and_slide()
	_update_animation()
	

# INFO Tank Pickup Function
func add_oxygen(amount: float):
	current_oxygen += amount
	
func _jump():
	if jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount -= 1

func _inputPauseReset(time):
	await get_tree().create_timer(time).timeout
	movementInputMonitoring = Vector2(true, true)

func _decelerate(delta, vertical):
	if !vertical:
		if (abs(velocity.x) > 0) and (abs(velocity.x) <= abs(deceleration * delta)):
			velocity.x = 0 
		elif velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta
	elif vertical and velocity.y > 0:
		velocity.y += deceleration * delta

func _update_animation() -> void:
	if velocity.x > 1.0:
		animated_sprite.flip_h = false
	elif velocity.x < -1.0:
		animated_sprite.flip_h = true

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif abs(velocity.x) > 1.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
