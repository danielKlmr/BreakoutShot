extends Node

# Singleton
@onready var game_variables = get_node("/root/GameVariables")

enum game_states {
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
var cue_ball

@onready var head_string = get_node("/root/Table/PlayingSurface/HeadString")
@onready var Gui = get_node("/root/Table/GUI Layer")
@onready var Table = get_node("/root/Table")
@onready var PlayingSurface = get_node("/root/Table/PlayingSurface")
@onready var UIAttempts = get_node("/root/Table/GUI Layer/HUD/Stats/Attempts Value")
@onready var UIFouls = get_node("/root/Table/GUI Layer/HUD/Stats/Fouls Value")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
		if !_balls_moving():
			Gui.show_foul()
			set_turn_state(turn_states.PlaceBallKitchen)

func _balls_moving():
	var moving = false

	for ball in Table.get_node("PlayingSurface/Balls").get_children():			#if ball.linear_velocity.length_squared() > 5:
		if !ball.is_sleeping():
			moving = true
			break
	
	return moving
			
func set_game_state(state):
	current_game_state = state
	if state == game_states.Lost:
		Gui.open_lost_menu()
	elif state == game_states.Win:
		Gui.open_win_menu()
		
func set_turn_state(state):
	current_turn_state = state
	if state == turn_states.PlaceBall:
		Gui.show_place_cue()
		Table.set_balls_static(true)
	if state == turn_states.PlaceBallKitchen:
		if self.cue_ball:
			Table.delete_ball(self.cue_ball)
		self.cue_ball = Table.setup_cue_ball()
		print("Cb setup")
		Table.set_balls_static(true)
	elif state == turn_states.Play:
		if !cue_ball.is_connected("hole_in", Callable(self, "_cue_ball_in")):
			cue_ball.connect("hole_in", Callable(self, "_cue_ball_in")) # TODO called everytime gameplay gets set to Play
		if current_game_state == game_states.Break:
			set_game_state(game_states.Pocketing)
		cue_ball.get_node("ReadyCircle").animate()
	elif state == turn_states.Hit:
		increase_attempts_counter()
	elif state == turn_states.Foul:
		increase_fouls_counter()

func play_game(cue_ball):
	increase_attempts_counter()
	increase_fouls_counter()
	set_game_state(game_states.Break)
	set_turn_state(turn_states.PlaceBall)
	self.cue_ball = cue_ball
	print(self.cue_ball)
	
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
			_project_to_head_string(Table.get_node('PlayingSurface').get_local_mouse_position())
		elif(current_turn_state == turn_states.PlaceBallKitchen):
			pass
			#_place_in_kitchen(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if current_turn_state == turn_states.PlaceBall:
				Table.set_balls_static(false)
				current_turn_state = turn_states.Wait # Wait for a frame, so that the ball gets not played
			elif current_turn_state == turn_states.PlaceBallKitchen:
				var ball_positioner = Table.get_node("PlayingSurface/BallPositioner")
				var cue_ball_position = ball_positioner.get_position()
				cue_ball.set_position(cue_ball_position)
				cue_ball.get_node("CollisionShape2D").set_disabled(false)
				cue_ball.set_freeze_enabled(false)
				ball_positioner.remove_child(cue_ball)
				Table.get_node("PlayingSurface/Balls").add_child(cue_ball)
				ball_positioner.queue_free()
				Table.set_balls_static(false)
				current_turn_state = turn_states.Wait

func _project_to_head_string(position):
	#position = Table.convert_global_position_to_scaled_position(position)
	var projected_position = head_string.get_curve().get_closest_point(position)
	if (projected_position - Vector2(PlayingSurface.head_spot_position)).length() < game_variables.SNAPPING_DISTANCE:
		self.cue_ball.set_position(PlayingSurface.head_spot_position)
	else:
		self.cue_ball.set_position(projected_position)

func _cue_ball_in(ball_number):
	set_turn_state(turn_states.Foul)
