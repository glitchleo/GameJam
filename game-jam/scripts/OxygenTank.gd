extends Area2D

@export var time_added: float = 5.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D:
		body.add_oxygen(time_added)

		set_deferred("monitoring", false)

		hide()

		$PickupSound.play()
		await $PickupSound.finished

		queue_free()
