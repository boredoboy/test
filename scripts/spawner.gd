class_name NeonSpawner
extends Node2D
## Spawns neon blocks on the right edge of the screen, moves them left
## and recycles them once they leave the screen.

const HEIGHTS: Array[float] = [64.0, 88.0, 112.0, 140.0]
const WIDTHS: Array[float] = [56.0, 64.0, 72.0]
const COLORS: Array[Color] = [
	Color(1.0, 0.176, 0.584), # magenta
	Color(1.0, 0.58, 0.0),    # orange
	Color(0.66, 0.33, 1.0),   # violet
	Color(1.0, 0.85, 0.2),    # yellow
]

## Packed scene of a single obstacle (an Area2D).
@export var obstacle_scene: PackedScene
## Container node that holds spawned obstacles.
@export var spawn_path: NodePath
## X coordinate (off-screen right) where new blocks appear.
@export var spawn_x := 800.0
## Y coordinate of the ground surface — blocks sit on top of it.
@export var floor_y := 1150.0

## Current scroll speed in pixels/second (assigned by Main every frame).
var speed := 320.0
## Whether the spawner is running.
var active := false

var _spawn_timer := 0.0


func _process(delta: float) -> void:
	if not active:
		return

	# Scroll every spawned obstacle and free the ones that left the screen.
	var world := get_node_or_null(spawn_path)
	if world == null:
		return

	for child in world.get_children():
		child.position.x -= speed * delta
		if child.position.x < -200.0:
			child.queue_free()

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn()
		# Time-based gaps keep the reaction distance fair while the game
		# speeds up: faster scroll => obstacles are spaced further apart.
		# The minimum (0.8s) guarantees the player has landed from the
		# previous jump (air time ~= 0.77s) before the next block arrives.
		_spawn_timer = randf_range(0.8, 1.35)


func reset() -> void:
	_spawn_timer = 0.0
	var world := get_node_or_null(spawn_path)
	if world != null:
		for child in world.get_children():
			child.queue_free()


func _spawn() -> void:
	if obstacle_scene == null:
		push_warning("Spawner: obstacle_scene is not assigned.")
		return
	var world := get_node_or_null(spawn_path)
	if world == null:
		return

	var height: float = HEIGHTS.pick_random()
	var width: float = WIDTHS.pick_random()

	var obstacle := obstacle_scene.instantiate()
	# Configure before add_child so _ready() sees the final values.
	obstacle.set("size", Vector2(width, height))
	obstacle.set("neon_color", COLORS.pick_random())
	obstacle.position = Vector2(spawn_x + width * 0.5, floor_y - height * 0.5)
	world.add_child(obstacle)
