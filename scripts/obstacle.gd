class_name NeonObstacle
extends Area2D
## Deadly neon block scrolling towards the player.

const NEON_COLORS: Array[Color] = [
	Color(1.0, 0.176, 0.584), # magenta
	Color(1.0, 0.58, 0.0),    # orange
	Color(0.66, 0.33, 1.0),   # violet
	Color(1.0, 0.85, 0.2),    # yellow
]

## Rectangle size; collision shape and visuals are generated from it.
@export var size := Vector2(64.0, 64.0)
@export var neon_color := Color(1.0, 0.176, 0.584)


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()


func _draw() -> void:
	var rect := Rect2(-size * 0.5, size)
	var dim := Color(neon_color.r, neon_color.g, neon_color.b, 0.14)
	# Soft neon halo.
	draw_rect(rect.grow(8.0), dim, true)
	# Dark body.
	draw_rect(rect, Color(0.05, 0.03, 0.1), true)
	# Bright border.
	draw_rect(rect, neon_color, false, 4.0)
	# Inner hazard stripes.
	var inner := rect.grow(-12.0)
	draw_rect(inner, Color(neon_color.r, neon_color.g, neon_color.b, 0.35), false, 2.0)
