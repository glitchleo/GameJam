extends StaticBody2D

@export_category("Wall Settings")
## Drag your Player node into this slot in the Inspector
@export var player: CharacterBody2D

func _physics_process(_delta):
	# Safety check to make sure the player exists
	if player != null:
		# Update ONLY our Y position to match the player's Y position.
		# We leave the X position alone so the walls don't move side-to-side!
		global_position.y = player.global_position.y
