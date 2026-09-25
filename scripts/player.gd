class_name NeonPlayer
extends CharacterBody2D
## Neon square player. Jumps on screen tap (or Space/Up on desktop).

signal died
signal jumped

const GRAVITY := 2800.0
const JUMP_VELOCITY := -1080.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER_TIME := 0.12

## Set to true by Main when the run starts.
var can_move := false
var alive := true

var _coyote := 0.0
var _jump_buffer := 0.0


func _ready() -> void:
	add_to_group("player")
	queue_redraw()


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote = maxf(_coyote - delta, 0.0)
		velocity.y += GRAVITY * delta

	_jump_buffer = maxf(_jump_buffer - delta, 0.0)

	if can_move and alive and _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_coyote = 0.0
		_jump_buffer = 0.0
		jumped.emit()

	# The runner never moves horizontally: the world scrolls towards him.
	velocity.x = 0.0
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if not can_move or not alive:
		return
	if event is InputEventScreenTouch and event.pressed:
		_jump_buffer = JUMP_BUFFER_TIME
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Fallback for setups without touch-from-mouse emulation.
		_jump_buffer = JUMP_BUFFER_TIME
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_UP or event.keycode == KEY_W:
			_jump_buffer = JUMP_BUFFER_TIME


func die() -> void:
	if not alive:
		return
	alive = false
	can_move = false
	velocity = Vector2.ZERO
	modulate = Color(1.0, 0.4, 0.4)
	died.emit()


func _draw() -> void:
	var half := 28.0
	var rect := Rect2(-half, -half, half * 2.0, half * 2.0)
	var neon := Color(0.0, 0.898, 1.0)
	# Soft neon halo.
	draw_rect(rect.grow(10.0), Color(neon.r, neon.g, neon.b, 0.10), true)
	draw_rect(rect.grow(5.0), Color(neon.r, neon.g, neon.b, 0.22), true)
	# Dark core + bright border.
	draw_rect(rect, Color(0.02, 0.03, 0.09), true)
	draw_rect(rect, neon, false, 4.0)
	# Magenta inner accent.
	draw_rect(rect.grow(-11.0), Color(1.0, 0.176, 0.584, 0.9), false, 2.0)
