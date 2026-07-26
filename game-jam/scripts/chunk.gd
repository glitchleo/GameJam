extends Node2D

@export_category("Spawning Logic")
## Drag your OxygenTank.tscn here in the inspector.
@export var oxygen_scene: PackedScene
## 0.0 is 0% chance, 1.0 is 100% chance.
@export_range(0.0, 1.0) var spawn_probability: float = 0.3 

func _ready():
	# 1. Safety check: Ensure an oxygen scene is assigned
	if oxygen_scene == null:
		return
		
	# 2. Get all the Marker2D points inside the SpawnPoints folder
	var points = $SpawnPoints.get_children()
	
	# 3. Loop through every single marker
	for point in points:
		# 4. Roll the virtual dice! randf() picks a random number between 0.0 and 1.0
		if randf() <= spawn_probability:
			# 5. We won the roll! Create the tank and place it exactly at the marker.
			var tank = oxygen_scene.instantiate()
			tank.position = point.position
			add_child(tank)
