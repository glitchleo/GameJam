extends Node2D

@export_category("Spawning Logic")
@export var oxygen_scene: PackedScene
@export_range(0.0, 1.0) var spawn_probability: float = 0.3 

func _ready():
	if oxygen_scene == null:
		return

	var points = $SpawnPoints.get_children()

	for point in points:
		if randf() <= spawn_probability:
			var tank = oxygen_scene.instantiate()
			tank.position = point.position
			add_child(tank)
