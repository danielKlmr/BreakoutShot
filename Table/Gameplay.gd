extends Node

# Singleton
onready var game_variables = get_node("/root/GameVariables")

enum game_states {None, PlaceBall, Wait, Play}
var current_game_state = game_states.None
var cue_ball

onready var head_string = get_node("/root/Table/HeadString")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if current_game_state == game_states.Wait:
		current_game_state = game_states.Play

func play_game(cue_ball):
	current_game_state = game_states.PlaceBall
	self.cue_ball = cue_ball
	
func _input(event):
	if(current_game_state == game_states.PlaceBall):
		if event is InputEventMouseMotion:
			var projected_position = head_string.get_curve().get_closest_point(event.position)
			if (projected_position - game_variables.head_spot_position).length() < game_variables.SNAPPING_DISTANCE:
				cue_ball.set_position(game_variables.head_spot_position)
			else:
				cue_ball.set_position(projected_position)
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if !event.pressed:
					current_game_state = game_states.Wait # Wait for a frame, so that the ball gets not played
