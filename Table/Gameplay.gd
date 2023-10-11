extends Node
## Gameplay
##
## Handles game states and turn states to keep the game running after the
## ruleset

signal place_cue_ball()
signal play()
signal hit_ball(number_attempts)
signal foul(number_fouls)
signal lost()
signal win()

enum GameStates {
	START,
	BREAK,
	POCKET,
	POCKET_EIGHT_BALL,
	LOST,
	WIN,
}
enum TurnStates {
	NONE, # 0
	PLACE_BALL, # 1 Place cue ball on line
	PLACE_BALL_KITCHEN, # 2 Place cue ball in kitchen
	PLAY, # 3
	HIT, # 4 Ball is moving
	CORRECT_HIT, # 5
	FOUL # 6
}

var current_game_state
var current_turn_state = TurnStates.NONE
var attempts
var fouls

@onready var playing_surface = get_parent().get_node("PlayingSurface")


func _physics_process(_delta):
	if current_turn_state == TurnStates.CORRECT_HIT:
		if !playing_surface.balls_moving:
			set_turn_state(TurnStates.PLAY)
	elif current_turn_state == TurnStates.HIT:
		# When no ball is pocketed
		if !playing_surface.balls_moving:
			set_turn_state(TurnStates.FOUL)
	elif current_turn_state == TurnStates.FOUL:
		# Check if balls are moving in case of cue ball in foul
		if !playing_surface.balls_moving:
			fouls += 1
			emit_signal("foul", fouls)
			set_turn_state(TurnStates.PLACE_BALL_KITCHEN)


func _input(event):
	# Place cue ball along head string
	if (
			event is InputEventMouseMotion
			and current_turn_state == TurnStates.PLACE_BALL
	):
		playing_surface.project_cue_ball_to_head_string()
	elif (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and !event.is_pressed()
	):
		# Place ball along headstring
		if current_turn_state == TurnStates.PLACE_BALL:
			set_turn_state(TurnStates.PLAY)
		# Place ball in kitchen
		elif current_turn_state == TurnStates.PLACE_BALL_KITCHEN:
			playing_surface.place_cue_ball_in_kitchen()
			set_turn_state(TurnStates.PLAY)


## Triggers actions when the game state is changed
func set_game_state(state: GameStates):
	current_game_state = state
	
	if state == GameStates.START:
		playing_surface.connect("ball_removed", Callable(self, "_ball_removed"))
		attempts = 0
		fouls = 0
		set_game_state(GameStates.BREAK)
		set_turn_state(TurnStates.PLACE_BALL)
	elif state == GameStates.LOST:
		emit_signal("lost")
	elif state == GameStates.WIN:
		emit_signal("win")


## Triggers actions when the turn state is changed
func set_turn_state(state: TurnStates):
	current_turn_state = state
	
	if state == TurnStates.PLACE_BALL:
		emit_signal("place_cue_ball")
		playing_surface.set_balls_static(true)
	elif state == TurnStates.PLACE_BALL_KITCHEN:
		playing_surface.setup_cue_ball(true)
	elif state == TurnStates.PLAY:
		if current_game_state == GameStates.BREAK:
			set_game_state(GameStates.POCKET)
		emit_signal("play")
		print("playwuhu")
	elif state == TurnStates.HIT:
		attempts += 1
		emit_signal("hit_ball", attempts)


## When signal is received, that the cue ball stroke an object ball
func strike_object_ball(other_ball_number):
	# Relevant if turn state is a (yet invalid) hit
	if current_turn_state == TurnStates.HIT:
		if current_game_state != GameStates.POCKET_EIGHT_BALL:
			# Not valid if other ball is eight ball
			if other_ball_number != playing_surface.EIGHT_BALL_NUMBER:
				set_turn_state(TurnStates.CORRECT_HIT)
			else:
				set_turn_state(TurnStates.FOUL)
		# Correct hit if only eight ball is left
		else:
			set_turn_state(TurnStates.CORRECT_HIT)


## Change game state to POCKET_EIGHT_BALL when only 1 ball, which must be the
## eight ball, is left.
func _ball_removed(ball_number, number_object_balls):
	if ball_number == 0:
		set_turn_state(TurnStates.FOUL)
	elif ball_number == playing_surface.EIGHT_BALL_NUMBER:
			if current_game_state != GameStates.POCKET_EIGHT_BALL:
				set_game_state(GameStates.LOST)
			else:
				set_game_state(GameStates.WIN)
	elif number_object_balls == 1:
		set_game_state(GameStates.POCKET_EIGHT_BALL)
