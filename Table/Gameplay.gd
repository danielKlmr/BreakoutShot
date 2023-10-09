extends Node

# Singleton
@onready var game_variables = get_node("/root/GameVariables")

enum game_states {
	Start,
	Break,
	Pocketing,
	PocketingEightBall,
	Lost,
	Win
}
var current_game_state
enum turn_states {
	None, # 0
	PlaceBall, # 1 Place cue ball on line
	PlaceBallKitchen, # 2 Place cue ball in kitchen
	Wait, # 3 Wait for one frame, then play
	Play, # 4
	Hit, # 5 Ball is moving
	CorrectHit, # 6
	Foul # 7
	}
var current_turn_state = turn_states.None
var attempts
var fouls

@onready var head_string = get_node("/root/Table/PlayingSurface/HeadString")
@onready var Gui = get_node("/root/Table/GUI Layer")
@onready var Table = get_node("/root/Table")
@onready var PlayingSurface = get_node("/root/Table/PlayingSurface")
@onready var UIAttempts = get_node("/root/Table/GUI Layer/HUD/Stats/Attempts Value")
@onready var UIFouls = get_node("/root/Table/GUI Layer/HUD/Stats/Fouls Value")


func _physics_process(delta):
	if current_turn_state == turn_states.Wait:
		set_turn_state(turn_states.Play)
	elif current_turn_state == turn_states.CorrectHit:
		if !_balls_moving():
			set_turn_state(turn_states.Play)
	elif current_turn_state == turn_states.Hit:
		if !_balls_moving():
			increase_fouls_counter() # TODO set to foul instead?
			Gui.show_foul()
			set_turn_state(turn_states.PlaceBallKitchen)
	elif current_turn_state == turn_states.Foul:
		print("jemals?")
		if !_balls_moving():
			Gui.show_foul()

func _balls_moving():
	var moving = false

	for ball in Table.get_node("PlayingSurface/Balls").get_children():			#if ball.linear_velocity.length_squared() > 5:
		if !ball.is_sleeping():
			moving = true
			break
	
	return moving
			
func set_game_state(state):
	current_game_state = state
	if state == game_states.Start:
		PlayingSurface.connect("ball_removed", Callable(self, "_ball_removed"))
		increase_attempts_counter()
		increase_fouls_counter()
		set_game_state(game_states.Break)
		set_turn_state(turn_states.PlaceBall)
	elif state == game_states.Lost:
		Gui.open_lost_menu()
	elif state == game_states.Win:
		Gui.open_win_menu()
		
func set_turn_state(state):
	current_turn_state = state
	if state == turn_states.PlaceBall:
		Gui.show_place_cue()
		Table.set_balls_static(true)
	elif state == turn_states.PlaceBallKitchen:
		PlayingSurface.setup_cue_ball(true)
		Table.set_balls_static(true)
	elif state == turn_states.Play:
		if current_game_state == game_states.Break:
			set_game_state(game_states.Pocketing)
		PlayingSurface._cue_ball.get_node("ReadyCircle").animate() # Private call
	elif state == turn_states.Hit:
		increase_attempts_counter()
	elif state == turn_states.Foul:
		increase_fouls_counter()
		set_turn_state(turn_states.PlaceBallKitchen)


func increase_attempts_counter():
	if attempts != null:
		attempts += 1
	else:
		attempts = 0
	UIAttempts.set_text(str(attempts))
	
func increase_fouls_counter():
	if fouls != null:
		fouls += 1
	else:
		fouls = 0
	UIFouls.set_text(str(fouls))
	
func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("debug"):
			print("GameState: " + str(current_turn_state))
			# TODO fix pause when aiming
	if event is InputEventMouseMotion:
		if(current_turn_state == turn_states.PlaceBall):
			PlayingSurface.project_cue_ball_to_head_string()
		elif(current_turn_state == turn_states.PlaceBallKitchen):
			pass
			#_place_in_kitchen(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if current_turn_state == turn_states.PlaceBall:
				Table.set_balls_static(false)
				current_turn_state = turn_states.Wait # Wait for a frame, so that the ball gets not played
			elif current_turn_state == turn_states.PlaceBallKitchen:
				PlayingSurface.place_cue_ball_in_kitchen()
				current_turn_state = turn_states.Wait


func _cue_ball_in():
	set_turn_state(turn_states.Foul)


## Change game state to PocketingEightBall when only 1 ball, which must be the
## eight ball, is left.
func _ball_removed(ball_number, number_object_balls):
	if ball_number == 0:
		_cue_ball_in()
	elif ball_number == PlayingSurface.EIGHT_BALL_NUMBER:
			if current_game_state != game_states.PocketingEightBall:
				set_game_state(game_states.Lost)
			else:
				set_game_state(game_states.Win)
	elif number_object_balls == 1:
		set_game_state(game_states.PocketingEightBall)
