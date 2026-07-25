extends Area2D

# How many seconds this tank adds to the countdown
@export var time_added: float = 5.0 

func _ready():
	# Connect the Area2D's built-in signal to our script through code
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the thing that touched the tank is the Player
	# We use the class_name you defined in your movement script!
	if body is PlatformerController2D:
		body.add_oxygen(time_added) # Send the time to the player
		queue_free() # Delete the oxygen tank from the level
