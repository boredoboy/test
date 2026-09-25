extends Node2D
## Main scene controller: game state, difficulty ramp, score and UI.

const BASE_SPEED := 320.0     # px/s — world scroll speed at start
const MAX_SPEED := 980.0      # px/s — top speed
const ACCELERATION := 9.0     # px/s added every second
const SCORE_RATE := 0.1       # score gained per pixel travelled

@onready var player: NeonPlayer = $Player
@onready var spawner: NeonSpawner = $Spawner
@onready var score_label: Label = $HUD/ScoreLabel
@onready var hint_label: Label = $HUD/HintLabel
@onready var game_over: Control = $HUD/GameOver
@onready var final_score_label: Label = $HUD/GameOver/Panel/VBox/FinalScore

var game_speed := BASE_SPEED
var score := 0.0
var running := false


func _ready() -> void:
	randomize()
	player.died.connect(_on_player_died)
	player.jumped.connect(_on_player_jumped)
	start_game()


func _process(delta: float) -> void:
	if not running:
		return

	# The game gradually speeds up...
	game_speed = minf(game_speed + ACCELERATION * delta, MAX_SPEED)
	spawner.speed = game_speed

	# ...and the score grows with the distance travelled.
	score += game_speed * delta * SCORE_RATE
	score_label.text = str(int(score))


func start_game() -> void:
	running = true
	game_speed = BASE_SPEED
	score = 0.0
	score_label.text = "0"
	hint_label.visible = true
	game_over.visible = false
	spawner.active = true


func _on_player_jumped() -> void:
	if hint_label.visible:
		hint_label.visible = false


func _on_player_died() -> void:
	running = false
	spawner.active = false
	final_score_label.text = "SCORE  %d" % int(score)
	game_over.visible = true


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
