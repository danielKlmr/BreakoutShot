extends Node2D
## Table Scene
##
## Game scene that holds the playing surface and ingame GUI

const BORDER_COLOR_SHIFT = 0.2
const BORDER_SATURATION_SHIFT = -0.1
const COLORS_TABLE = [
	"yellow",
	"violet",
	"blue",
	"red",
	"orange",
	"green",
	"dark_red",
]
# Field size (mm)
# https://de.wikipedia.org/wiki/Billardtisch_(Pool)
const POCKET_NODE_SIZE = 256
const SPOT_DRAWING_SIZE = 5
const STANDARD_BALL_DIAMETER = 57.2
const STANDARD_LENGTH = 2240
const STANDARD_WIDTH = 1120

var _mm_to_px_scaling_factor
var _pocket_node_overlap
var _ball_radius
var _balls = []
var _table_color
var _border_color
var _cue_ball
var _eight_ball
var _camera_zoom = 1
var _hole_offset = 38
var head_spot_position: Vector2i
var food_spot_position: Vector2i

@onready var Ball = preload("res://Ball/Ball.tscn")
@onready var BallPositioner = preload("res://Ball/BallPositioner.tscn")
@onready var CueBall = preload("res://Ball/CueBall.tscn")
@onready var Gameplay = get_node("Gameplay")
@onready var HeadString = get_node("PlayingSurface/HeadString")
@onready var PlayingSurface = get_node("PlayingSurface")
@onready var Camera = get_node("PlayingSurface/Camera3D")
@onready var GUI = get_node("GUI Layer/HUD")


func _ready():
	_set_table_color()
	_check_table_size()
	_setup_table()
	_setup_gui()
	_set_hud_space()
	_init_balls()
	setup_cue_ball()
	GameEngine.connect(
			"orientation_changed", Callable(self, "_change_table_orientation"))
	Gameplay.play_game(_cue_ball)


func _draw():
	# Draw the brighter background of the playing surface
	var background_size = GameEngine.original_window_size
	if GameEngine.current_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		background_size = Vector2i(background_size.y, background_size.x)
	draw_rect(Rect2(
			Vector2i(-GameVariables.hud_height, 0), background_size),
			_table_color)
	
	# Draw spots on playing surface
	draw_circle(food_spot_position, SPOT_DRAWING_SIZE, _border_color)
	draw_circle(head_spot_position, SPOT_DRAWING_SIZE, _border_color)
	draw_circle(
			Vector2i(PlayingSurface.position.x, PlayingSurface.position.y),
			SPOT_DRAWING_SIZE,
			_border_color)


func _process(_delta):
	#print(get_global_mouse_position())
	#print('curr' + str(GameVariables.curre))
	"""
	Manual scales canvas items to window size, so that UI elements can stay the same size when window size is changed.
	Therefore, stretch mode is disabled
	"""
	var viewport_size = Vector2(GameEngine.original_window_size)
	if GameEngine.current_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		viewport_size = Vector2(GameEngine.original_window_size.y, GameVariables.window_size.x)
	var current_window_height_without_hud = GameEngine.current_window_size.y - GameVariables.hud_height
	
	if GameEngine.current_window_size != viewport_size:
		var x_scale = GameEngine.current_window_size.x / viewport_size.x
		var y_scale = current_window_height_without_hud / viewport_size.y
		
		_camera_zoom = min(x_scale, y_scale)
		
		Camera.set_zoom(Vector2(_camera_zoom, _camera_zoom))
		# TODO make it work when paused


## Set the colors of the table borders and the playing surface
func _set_table_color():
	randomize()
	var color_index:int = randi() % len(COLORS_TABLE)
	var color_name = COLORS_TABLE[color_index]
	_border_color = GameVariables.COLORS[color_name]
	
	_table_color = _border_color
	_table_color.s += BORDER_SATURATION_SHIFT
	_table_color.r += BORDER_COLOR_SHIFT
	_table_color.g += BORDER_COLOR_SHIFT
	_table_color.b += BORDER_COLOR_SHIFT
	
	RenderingServer.set_default_clear_color(_border_color)


func _check_table_size():
	#var window = get_window().get_size()
	var window = Vector2i(1920, 1080) # get_viewport().size

	GameVariables.x_size = window.x
	GameVariables.y_size = window.y
			
	GameVariables.table_size.x = GameEngine.original_window_size.x - 2 * GameVariables.BORDER_THICKNESS
	GameVariables.table_size.y = round(GameVariables.table_size.x / 2)
	
	GameVariables.middle_spot_position = Vector2(GameEngine.original_window_size.x / 2, GameEngine.original_window_size.y / 2)
	
	PlayingSurface.position.x = GameEngine.original_window_size.x / 2
	PlayingSurface.position.y = GameEngine.original_window_size.y / 2
		
func _setup_table():
	# TODO CHECK https://github.com/vrojak/godot-multiplayer-billiards
	#https://www.youtube.com/watch?v=pJ0SW4ayXzU
	
	_mm_to_px_scaling_factor = GameVariables.table_size.x / STANDARD_LENGTH
	
	for hole in get_node("PlayingSurface/Holes").get_children():
		hole.scale.x = _mm_to_px_scaling_factor
		hole.scale.y = _mm_to_px_scaling_factor
		_pocket_node_overlap = floor(POCKET_NODE_SIZE * _mm_to_px_scaling_factor / 2)
	
	var top =  - (GameVariables.table_size.y / 2)
	var bottom = (GameVariables.table_size.y / 2)
	var left = -(GameVariables.table_size.x / 2)
	var right = (GameVariables.table_size.x / 2)
	
	get_node("PlayingSurface/Border").get_child(0).set_size(GameVariables.table_size.y - 2 * _pocket_node_overlap)
	get_node("PlayingSurface/Border").get_child(0).position = Vector2(left, 0)
	get_node("PlayingSurface/Border").get_child(2).set_size((GameVariables.table_size.x - 4 * _pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(2).position = Vector2(-(GameVariables.table_size.x - 4 * _pocket_node_overlap) / 4 - _pocket_node_overlap, top)
	get_node("PlayingSurface/Border").get_child(4).set_size((GameVariables.table_size.x - 4 * _pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(4).position = Vector2(((GameVariables.table_size.x - 4 * _pocket_node_overlap) / 4 + _pocket_node_overlap), top)
	get_node("PlayingSurface/Border").get_child(1).set_size(GameVariables.table_size.y - 2 * _pocket_node_overlap)
	get_node("PlayingSurface/Border").get_child(1).position = Vector2(right, 0)
	get_node("PlayingSurface/Border").get_child(3).set_size((GameVariables.table_size.x - 4 * _pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(3).position = Vector2(-(GameVariables.table_size.x - 4 * _pocket_node_overlap) / 4 - _pocket_node_overlap, bottom)
	get_node("PlayingSurface/Border").get_child(5).set_size((GameVariables.table_size.x - 4 * _pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(5).position = Vector2(((GameVariables.table_size.x - 4 * _pocket_node_overlap) / 4 + _pocket_node_overlap), bottom)
	
	get_node("PlayingSurface/Holes").get_node("Cutout Corner").position = Vector2(left, top)
	get_node("PlayingSurface/Holes").get_node("Cutout Corner2").position = Vector2(right, top)
	get_node("PlayingSurface/Holes").get_node("Cutout Middle2").position = Vector2(0, top)
	get_node("PlayingSurface/Holes").get_node("Cutout Corner4").position = Vector2(left, bottom)
	get_node("PlayingSurface/Holes").get_node("Cutout Corner3").position = Vector2(right, bottom)
	get_node("PlayingSurface/Holes").get_node("Cutout Middle").position = Vector2(0, bottom)
	
	for border in get_node("PlayingSurface/Border").get_children():
		border.set_color(_border_color)
		
	for cutout in get_node("PlayingSurface/Holes").get_children():
		cutout.get_node("Sprite2D").set_modulate(_border_color)
		
	_ball_radius = round(_mm_to_px_scaling_factor * STANDARD_BALL_DIAMETER / 2)
		
	GameVariables.head_string_position = GameVariables.table_size.x * 1 / 4 # 3/4 of the tables length
	var head_line_top =  - (GameVariables.table_size.y / 2) + _ball_radius
	var head_line_bottom = (GameVariables.table_size.y / 2) - _ball_radius
	HeadString.get_curve().clear_points()
	HeadString.get_curve().add_point(Vector2(GameVariables.head_string_position, head_line_top))
	HeadString.get_curve().add_point(Vector2(GameVariables.head_string_position, head_line_bottom))
	queue_redraw() # TODO Remove
	
	head_spot_position = Vector2(GameVariables.head_string_position, 0)
	food_spot_position = Vector2(-GameVariables.table_size.x * 1 / 4, 0)
	
func _setup_gui():
	GameVariables.hud_height = GUI.get_size().y + GameVariables.HUD_PADDING
	
func _set_hud_space():
	Camera.offset.y = - GameVariables.hud_height / 2
	# Only half because playing surface is scaled to window withoud hud. Therefore, half of the hud size is already free at top and bottom


func _init_balls():
	var colors = [
		GameVariables.COLORS["yellow"],
		GameVariables.COLORS["blue"],
		GameVariables.COLORS["red"],
		GameVariables.COLORS["violet"],
		GameVariables.COLORS["orange"],
		GameVariables.COLORS["green"],
		GameVariables.COLORS["dark_red"],
		GameVariables.COLORS["black"]]
		
	var suits = GameVariables.suits
		
	for ball_index in GameVariables.NUMBER_OBJECT_BALLS:
		var suit
		if ball_index < GameVariables.EIGHT_BALL_NUMBER:
			suit = suits.Solid
		else:
			suit = suits.Stripe
		var ball = Ball.instantiate().init(_ball_radius, ball_index + 1, colors[ball_index % len(colors)], Vector2(0,0), suit)
		_balls.append(ball)
		
		
	_eight_ball = _balls[7]
	_balls.remove_at(7)
	
	randomize()
	_balls.shuffle()
	if _balls[-5].suit == _balls[-1].suit:
		for ball_number in range(GameVariables.NUMBER_OBJECT_BALLS - 1):
			var ball = _balls[ball_number]
			if ball.suit != _balls[-1].suit:
				_balls.erase(ball)
				_balls.insert(GameVariables.NUMBER_OBJECT_BALLS - 6, ball)
				break

	_balls.insert(4, _eight_ball) # Insert always after the given index
	var assignment_iterator = 0
	var distance_rows = _ball_radius * 2 + 7
	var distance_columns = _ball_radius * 2 + 2
	
	# Place _balls from the front column to the rear column
	for column in range(5):
		var x_position = food_spot_position.x - (column * distance_columns)
		for rows in range(0, column+1):
			var y_position = food_spot_position.y - ((column * distance_rows) / 2) + (rows) * distance_rows 
			var ball = _balls[assignment_iterator]
			ball.set_position(Vector2(x_position, y_position))
			ball.set_rotation(randf_range(0, 2*PI)) # TODO: Randomize?
			get_node("PlayingSurface/Balls").add_child(ball)
			assignment_iterator += 1
			
	
func setup_cue_ball():
	self._cue_ball = CueBall.instantiate().init(_ball_radius, 0, GameVariables.COLORS["white"], head_spot_position)
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
	_balls.erase(ball)
	ball.queue_free()
	
	if ball_number == 0:
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
	var number_balls = len(_balls)
	return number_balls
	
func set_balls_static(value: bool):
	for ball in _balls:
		ball.set_freeze_enabled(value)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_node("GUI Layer").open_pause_menu()
			
func convert_global_position_to_scaled_position(position_global:Vector2i):
	var position_scaled = Vector2i(position_global / _camera_zoom)
	#var position_scaled = get_viewport().get_viewport_transform() * Vector2(position_global)
	
	return position_scaled
