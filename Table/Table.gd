extends Node2D
## Table Scene
##
## Game scene that holds the playing surface and ingame GUI

var _cue_ball
var _camera_zoom = 1
var _hole_offset = 38

@onready var BallPositioner = preload("res://Ball/BallPositioner.tscn")
@onready var CueBall = preload("res://Ball/CueBall.tscn")
@onready var Gameplay = get_node("Gameplay")
@onready var PlayingSurface = get_node("PlayingSurface")
@onready var Camera = get_node("PlayingSurface/Camera3D")
@onready var GUI = get_node("GUI Layer/HUD")


func _ready():
	_setup_gui()
	_set_hud_space()
	setup_cue_ball()
	GameEngine.connect(
			"orientation_changed", Callable(self, "_change_table_orientation"))
	Gameplay.play_game(_cue_ball)


func _process(_delta):
	#print(get_global_mouse_position())
	#print('curr' + str(GameVariables.curre))
	"""
	Manual scales canvas items to window size, so that UI elements can stay the same size when window size is changed.
	Therefore, stretch mode is disabled
	"""
	var viewport_size = Vector2(GameEngine.original_window_size)
	if GameEngine.current_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		viewport_size = Vector2(GameEngine.original_window_size.y, GameEngine.original_window_size.x)
	var current_window_height_without_hud = GameEngine.current_window_size.y - GameVariables.hud_height
	
	if GameEngine.current_window_size != viewport_size:
		var x_scale = GameEngine.current_window_size.x / viewport_size.x
		var y_scale = current_window_height_without_hud / viewport_size.y
		
		_camera_zoom = min(x_scale, y_scale)
		
		Camera.set_zoom(Vector2(_camera_zoom, _camera_zoom))
		# TODO make it work when paused

	
func _setup_gui():
	GameVariables.hud_height = GUI.get_size().y + GameVariables.HUD_PADDING
	
func _set_hud_space():
	Camera.offset.y = - GameVariables.hud_height / 2
	# Only half because playing surface is scaled to window withoud hud. Therefore, half of the hud size is already free at top and bottom
			
	
func setup_cue_ball():
	self._cue_ball = CueBall.instantiate().init(PlayingSurface._ball_radius, 0, GameVariables.COLORS["white"], PlayingSurface.head_spot_position)
	_cue_ball.set_rotation(randf_range(0, 2*PI)) # TODO: Randomize?
	
	if Gameplay.current_turn_state == Gameplay.turn_states.PlaceBallKitchen:
		var _cue_ball_positioner = BallPositioner.instantiate().init(self._cue_ball)
		get_node('PlayingSurface').add_child(_cue_ball_positioner)
	else:
		print('Now??')
		get_node("PlayingSurface/Balls").add_child(self._cue_ball)
	return self._cue_ball
	

func _change_table_orientation(
		new_orientation: GameEngine.WindowOrientationModes):
	if new_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		PlayingSurface.set_rotation(PI/2)
	else:
		PlayingSurface.set_rotation(0)
	
func delete_ball(ball):
	var ball_number = ball.number
	PlayingSurface._balls.erase(ball)
	ball.queue_free()
	
	if ball_number == 0:
		print("whydelete?")
		Gameplay.cue_ball = null
	elif ball_number == GameVariables.EIGHT_BALL_NUMBER:
		if Gameplay.current_game_state != Gameplay.game_states.PocketingEightBall:
			Gameplay.set_game_state(Gameplay.game_states.Lost)
		else:
			Gameplay.set_game_state(Gameplay.game_states.Win)
	
	var number_object_balls = count_object_balls()
	
	# Change game state to PocketingEightBall when only 1 ball, which must be the 8 ball, is left
	if number_object_balls == 1:
		if Gameplay.current_game_state != Gameplay.game_states.PocketingEightBall:
			Gameplay.set_game_state(Gameplay.game_states.PocketingEightBall)

func count_object_balls():
	var number_balls = len(PlayingSurface._balls)
	return number_balls
	
func set_balls_static(value: bool):
	for ball in PlayingSurface._balls:
		ball.set_freeze_enabled(value)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_node("GUI Layer").open_pause_menu()
			
func convert_global_position_to_scaled_position(position_global:Vector2i):
	var position_scaled = Vector2i(position_global / _camera_zoom)
	#var position_scaled = get_viewport().get_viewport_transform() * Vector2(position_global)
	
	return position_scaled
