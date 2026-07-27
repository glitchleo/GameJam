extends Node2D

@export_category("Generator Settings")
@export var chunk_scenes: Array[PackedScene]
@export var player: CharacterBody2D
@export var chunk_height: float = 360.0 
@export var spawn_ahead_amount: int = 3

var current_spawn_y: float = 0.0

func _ready():
	for i in range(spawn_ahead_amount):
		spawn_chunk()

func _process(_delta):
	if player != null and player.global_position.y < (current_spawn_y + (chunk_height * 2)):
		spawn_chunk()

func spawn_chunk():
	var random_index = randi() % chunk_scenes.size()
	var selected_chunk = chunk_scenes[random_index]

	var chunk_instance = selected_chunk.instantiate()

	chunk_instance.global_position = Vector2(0, current_spawn_y)

	if randf() > 0.5:
		chunk_instance.scale.x = -1

	add_child(chunk_instance)

	current_spawn_y -= chunk_height
