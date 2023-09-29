extends Node2D

# Singleton
@onready var game_variables = get_node("/root/GameVariables")

const TABLE_COLORS = [
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
var STANDARD_LENGTH = 2240
var STANDARD_WIDTH = 1120
var STANDARD_BALL_DIAMETER = 57.2

# Member variables
var POCKET_NODE_SIZE = 256
var mm_to_px_scaling_factor
var pocket_node_overlap
var ball_radius
var balls = []
var table_color
var border_color
var cue_ball
var eight_ball
var camera_zoom = 1
var hole_offset = 38
var BORDER_SATURATION_SHIFT = 0.2
@onready var GAMEPLAY = get_node("Gameplay")
@onready var HeadString = get_node("PlayingSurface/HeadString")
@onready var Ball = preload("res://Ball/Ball.tscn")
@onready var CueBall = preload("res://Ball/CueBall.tscn")
@onready var BallPositioner = preload("res://Ball/BallPositioner.tscn")
@onready var playingSurface = get_node("PlayingSurface")
@onready var camera = get_node("PlayingSurface/Camera3D")
@onready var GUI = get_node("GUI Layer/HUD")

func _ready():
	_set_color()
	_check_table_size()
	_setup_table()
	_setup_gui()
	_set_hud_space()
	_init_balls()
	setup_cue_ball()
	GAMEPLAY.play_game(cue_ball)
	
func _draw():
	var table_size = Vector2(game_variables.window_size.x, game_variables.window_size.y)
	if game_variables.current_orientation == game_variables.orientation.Portrait:
		table_size = Vector2(game_variables.window_size.y, game_variables.window_size.x)
	draw_rect(Rect2(Vector2(0, 0), table_size), table_color)
	draw_polyline(HeadString.get_curve().get_baked_points(), game_variables.COLORS["blue"], 2.0)
	draw_circle(game_variables.food_spot_position, 5, border_color)
	draw_circle(game_variables.head_spot_position, 5, border_color)
	draw_circle(Vector2(playingSurface.position.x, playingSurface.position.y), 5, border_color)

func _process(delta):
	#print(get_global_mouse_position())
	#print('curr' + str(game_variables.curre))
	"""
	Manual scales canvas items to window size, so that UI elements can stay the same size when window size is changed.
	Therefore, stretch mode is disabled
	"""
	game_variables.current_window_size = Vector2(get_viewport().size)
	var viewport_size = Vector2(game_variables.window_size)
	if game_variables.current_orientation == game_variables.orientation.Portrait:
		viewport_size = Vector2(game_variables.window_size.y, game_variables.window_size.x)
	var current_window_height_without_hud = game_variables.current_window_size.y - game_variables.hud_height
	
	if game_variables.current_window_size != viewport_size:
		var x_scale = game_variables.current_window_size.x / viewport_size.x
		var y_scale = current_window_height_without_hud / viewport_size.y
		
		camera_zoom = min(x_scale, y_scale)
		
		camera.set_zoom(Vector2(camera_zoom, camera_zoom))
		# TODO make it work when paused
		
	if game_variables.current_orientation == game_variables.orientation.Landscape:
		if game_variables.current_window_size.x * 1.1 < game_variables.current_window_size.y:
			game_variables.current_orientation = game_variables.orientation.Portrait
			playingSurface.set_rotation(PI/2)
			#playingSurface.position.x = game_variables.window_size.y / 2
			#playingSurface.position.y = game_variables.window_size.x / 2
	else:
		if game_variables.current_window_size.y * 1.1 < game_variables.current_window_size.x:
			game_variables.current_orientation = game_variables.orientation.Landscape
			playingSurface.set_rotation(0)
			#playingSurface.position.x = game_variables.window_size.x / 2
			#playingSurface.position.y = game_variables.window_size.y / 2

func _set_color():
	randomize()
	var color_index:int = randi() % len(TABLE_COLORS)
	var color_name = TABLE_COLORS[color_index]
	border_color = game_variables.COLORS[color_name]
	
	table_color = border_color
	table_color.s -= 0.1
	table_color.r += BORDER_SATURATION_SHIFT
	table_color.g += BORDER_SATURATION_SHIFT
	table_color.b += BORDER_SATURATION_SHIFT
	
	RenderingServer.set_default_clear_color(border_color)

func _check_table_size():
	#var window = get_window().get_size()
	var window = Vector2i(1920, 1080) # get_viewport().size

	game_variables.x_size = window.x
	game_variables.y_size = window.y
	
	game_variables.window_size = Vector2i(
			ProjectSettings.get("display/window/size/viewport_width"),
			ProjectSettings.get("display/window/size/viewport_height"))
			
	game_variables.table_size.x = game_variables.window_size.x - 2 * game_variables.BORDER_THICKNESS
	game_variables.table_size.y = round(game_variables.table_size.x / 2)
	
	game_variables.middle_spot_position = Vector2(game_variables.window_size.x / 2, game_variables.window_size.y / 2)
	
	playingSurface.position.x = game_variables.window_size.x / 2
	playingSurface.position.y = game_variables.window_size.y / 2
		
func _setup_table():
	# TODO CHECK https://github.com/vrojak/godot-multiplayer-billiards
	#https://www.youtube.com/watch?v=pJ0SW4ayXzU
	
	mm_to_px_scaling_factor = game_variables.table_size.x / STANDARD_LENGTH
	
	for hole in get_node("PlayingSurface/Holes").get_children():
		hole.scale.x = mm_to_px_scaling_factor
		hole.scale.y = mm_to_px_scaling_factor
		pocket_node_overlap = floor(POCKET_NODE_SIZE * mm_to_px_scaling_factor / 2)
	
	var top =  - (game_variables.table_size.y / 2)
	var bottom = (game_variables.table_size.y / 2)
	var left = -(game_variables.table_size.x / 2)
	var right = (game_variables.table_size.x / 2)
	
	get_node("PlayingSurface/Border").get_child(0).set_size(game_variables.table_size.y - 2 * pocket_node_overlap)
	get_node("PlayingSurface/Border").get_child(0).position = Vector2(left, 0)
	get_node("PlayingSurface/Border").get_child(2).set_size((game_variables.table_size.x - 4 * pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(2).position = Vector2(-(game_variables.table_size.x - 4 * pocket_node_overlap) / 4 - pocket_node_overlap, top)
	get_node("PlayingSurface/Border").get_child(4).set_size((game_variables.table_size.x - 4 * pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(4).position = Vector2(((game_variables.table_size.x - 4 * pocket_node_overlap) / 4 + pocket_node_overlap), top)
	get_node("PlayingSurface/Border").get_child(1).set_size(game_variables.table_size.y - 2 * pocket_node_overlap)
	get_node("PlayingSurface/Border").get_child(1).position = Vector2(right, 0)
	get_node("PlayingSurface/Border").get_child(3).set_size((game_variables.table_size.x - 4 * pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(3).position = Vector2(-(game_variables.table_size.x - 4 * pocket_node_overlap) / 4 - pocket_node_overlap, bottom)
	get_node("PlayingSurface/Border").get_child(5).set_size((game_variables.table_size.x - 4 * pocket_node_overlap) / 2)
	get_node("PlayingSurface/Border").get_child(5).position = Vector2(((game_variables.table_size.x - 4 * pocket_node_overlap) / 4 + pocket_node_overlap), bottom)
	
	get_node("PlayingSurface/Holes").get_node("Cutout Corner").position = Vector2(left, top)
	get_node("PlayingSurface/Holes").get_node("Cutout Corner2").position = Vector2(right, top)
	get_node("PlayingSurface/Holes").get_node("Cutout Middle2").position = Vector2(0, top)
	get_node("PlayingSurface/Holes").get_node("Cutout Corner4").position = Vector2(left, bottom)
	get_node("PlayingSurface/Holes").get_node("Cutout Corner3").position = Vector2(right, bottom)
	get_node("PlayingSurface/Holes").get_node("Cutout Middle").position = Vector2(0, bottom)
	
	for border in get_node("PlayingSurface/Border").get_children():
		border.set_color(border_color)
		
	for cutout in get_node("PlayingSurface/Holes").get_children():
		cutout.get_node("Sprite2D").set_modulate(border_color)
		
	ball_radius = round(mm_to_px_scaling_factor * STANDARD_BALL_DIAMETER / 2)
		
	game_variables.head_string_position = game_variables.table_size.x * 1 / 4 # 3/4 of the tables length
	var head_line_top =  - (game_variables.table_size.y / 2) + ball_radius
	var head_line_bottom = (game_variables.table_size.y / 2) - ball_radius
	HeadString.get_curve().clear_points()
	HeadString.get_curve().add_point(Vector2(game_variables.head_string_position, head_line_top))
	HeadString.get_curve().add_point(Vector2(game_variables.head_string_position, head_line_bottom))
	queue_redraw() # TODO Remove
	
	game_variables.head_spot_position = Vector2(game_variables.head_string_position, 0)
	game_variables.food_spot_position = Vector2(-game_variables.table_size.x * 1 / 4, 0)
	
func _setup_gui():
	game_variables.hud_height = GUI.get_size().y + game_variables.HUD_PADDING
	
func _set_hud_space():
	camera.offset.y = - game_variables.hud_height / 2
	# Only half because playing surface is scaled to window withoud hud. Therefore, half of the hud size is already free at top and bottom


func _init_balls():
	var colors = [
		game_variables.COLORS["yellow"],
		game_variables.COLORS["blue"],
		game_variables.COLORS["red"],
		game_variables.COLORS["violet"],
		game_variables.COLORS["orange"],
		game_variables.COLORS["green"],
		game_variables.COLORS["dark_red"],
		game_variables.COLORS["black"]]
		
	var suits = game_variables.suits
		
	for ball_index in game_variables.NUMBER_OBJECT_BALLS:
		var suit
		if ball_index < game_variables.EIGHT_BALL_NUMBER:
			suit = suits.Solid
		else:
			suit = suits.Stripe
		var ball = Ball.instantiate().init(ball_radius, ball_index + 1, colors[ball_index % len(colors)], Vector2(0,0), suit)
		balls.append(ball)
		
		
	eight_ball = balls[7]
	balls.remove_at(7)
	
	randomize()
	balls.shuffle()
	if balls[-5].suit == balls[-1].suit:
		for ball_number in range(game_variables.NUMBER_OBJECT_BALLS - 1):
			var ball = balls[ball_number]
			if ball.suit != balls[-1].suit:
				balls.erase(ball)
				balls.insert(game_variables.NUMBER_OBJECT_BALLS - 6, ball)
				break

	balls.insert(4, eight_ball) # Insert always after the given index
	var assignment_iterator = 0
	var distance_rows = ball_radius * 2 + 7
	var distance_columns = ball_radius * 2 + 2
	
	# Place balls from the front column to the rear column
	for column in range(5):
		var x_position = game_variables.food_spot_position.x - (column * distance_columns)
		for rows in range(0, column+1):
			var y_position = game_variables.food_spot_position.y - ((column * distance_rows) / 2) + (rows) * distance_rows 
			var ball = balls[assignment_iterator]
			ball.set_position(Vector2(x_position, y_position))
			ball.set_rotation(randf_range(0, 2*PI)) # TODO: Randomize?
			get_node("PlayingSurface/Balls").add_child(ball)
			assignment_iterator += 1
			
	
func setup_cue_ball():
	self.cue_ball = CueBall.instantiate().init(ball_radius, 0, game_variables.COLORS["white"], game_variables.head_spot_position)
	cue_ball.set_rotation(randf_range(0, 2*PI)) # TODO: Randomize?
	
	if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.PlaceBallKitchen:
		var cue_ball_positioner = BallPositioner.instantiate().init(self.cue_ball)
		get_node('PlayingSurface').add_child(cue_ball_positioner)
	else:
		print('Now??')
		get_node("PlayingSurface/Balls").add_child(self.cue_ball)
	return self.cue_ball
	
func delete_ball(ball):
	var ball_number = ball.number
	balls.erase(ball)
	ball.queue_free()
	
	if ball_number == 0:
		GAMEPLAY.cue_ball = null
	elif ball_number == game_variables.EIGHT_BALL_NUMBER:
		if GAMEPLAY.current_game_state != GAMEPLAY.game_states.PocketingEightBall:
			GAMEPLAY.set_game_state(GAMEPLAY.game_states.Lost)
		else:
			GAMEPLAY.set_game_state(GAMEPLAY.game_states.Win)
	
	var number_object_balls = count_object_balls()
	
	# Change game state to PocketingEightBall when only 1 ball, which must be the 8 ball, is left
	if number_object_balls == 1:
		if GAMEPLAY.current_game_state != GAMEPLAY.game_states.PocketingEightBall:
			GAMEPLAY.set_game_state(GAMEPLAY.game_states.PocketingEightBall)

func count_object_balls():
	var number_balls = len(balls)
	return number_balls
	
func set_balls_static(value: bool):
	for ball in balls:
		ball.set_freeze_enabled(value)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_node("GUI Layer").open_pause_menu()
			
func convert_global_position_to_scaled_position(position_global:Vector2i):
	var position_scaled = Vector2i(position_global / camera_zoom)
	#var position_scaled = get_viewport().get_viewport_transform() * Vector2(position_global)
	
	return position_scaled
