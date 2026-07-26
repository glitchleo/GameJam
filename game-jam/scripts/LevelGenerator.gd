extends Node2D

@export_category("Generator Settings")
## Drag and drop your Chunk_01.tscn, Chunk_02.tscn, etc. into this array in the Inspector.
@export var chunk_scenes: Array[PackedScene]
## Drag your Player node into this slot in the Inspector so the script can track their height.
@export var player: CharacterBody2D
## The exact pixel height of your chunks (e.g., 360).
@export var chunk_height: float = 360.0 
## How many chunks to spawn ahead of the player so they never see the void.
@export var spawn_ahead_amount: int = 3

# This keeps track of the Y-coordinate where the NEXT chunk should spawn.
# (Remember, moving UP in Godot means negative Y values).
var current_spawn_y: float = 0.0

func _ready():
	# When the game starts, spawn the first few chunks immediately.
	for i in range(spawn_ahead_amount):
		spawn_chunk()

func _process(_delta):
	# Check if the player has climbed high enough to need a new chunk.
	# We check if their Y position is getting close to our highest spawned chunk.
	if player != null and player.global_position.y < (current_spawn_y + (chunk_height * 2)):
		spawn_chunk()

func spawn_chunk():
	# 1. Pick a random chunk from the array
	var random_index = randi() % chunk_scenes.size()
	var selected_chunk = chunk_scenes[random_index]
	
	# 2. Create an instance of that chunk
	var chunk_instance = selected_chunk.instantiate()
	
	# 3. Position it exactly above the last one
	chunk_instance.global_position = Vector2(0, current_spawn_y)
	
	# 4. The Mirror Parameter: 50% chance to flip horizontally for extra variety
	if randf() > 0.5:
		chunk_instance.scale.x = -1
		
	# 5. Add it to the game world
	add_child(chunk_instance)
	
	# 6. Move our target spawn height UP for the next time this function runs
	current_spawn_y -= chunk_height
