extends Area2D

# How many seconds this tank adds to the countdown
@export var time_added: float = 5.0 

func _ready():
	# Connect the Area2D's built-in signal to our script through code
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D:
		body.add_oxygen(time_added)

		# Prevent collecting the tank again.
		set_deferred("monitoring", false)

		# Remove the tank visually.
		hide()

		# Play the sound before deleting the tank.
		$PickupSound.play()
		await $PickupSound.finished

		queue_free()
