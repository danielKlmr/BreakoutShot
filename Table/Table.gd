extends Node2D

# Singleton
onready var game_variables = get_node("/root/GameVariables")

# Field size (mm)
# https://de.wikipedia.org/wiki/Billardtisch_(Pool)
var STANDARD_LENGTH = 2240
var STANDARD_WIDTH = 1120
var STANDARD_BALL_DIAMETER = 57.2

# Member variables
var mm_to_px_scaling_factor
var ball_radius
var balls = []
var table_color
var border_color
var cue_ball
var eight_ball
var hole_offset = 38
var BORDER_SATURATION_SHIFT = 0.2
onready var GAMEPLAY = get_node("Gameplay")
onready var HeadString = get_node("HeadString")
onready var Ball = preload("res://Ball/Ball.tscn")
onready var BallPositioner = preload("res://Ball/BallPositioner.tscn")
onready var cameraPosition = get_node("CameraPosition")
onready var camera = get_node("CameraPosition/Camera")

func _ready():
	_set_color()
	_check_table_size()
	_setup_table()
	_init_balls()
	setup_cue_ball()
	GAMEPLAY.play_game(cue_ball)
	
func _draw():
	draw_polyline(HeadString.get_curve().get_baked_points(), game_variables.COLORS["blue"], 2.0)
	draw_circle(game_variables.food_spot_position, 5, border_color)
	draw_circle(game_variables.head_spot_position, 5, border_color)
	draw_circle(Vector2(cameraPosition.position.x, cameraPosition.position.y), 5, border_color)

func _set_color():
	randomize()
	var color_index:int = randi() % len(game_variables.TABLE_COLORS)
	table_color = game_variables.TABLE_COLORS[color_index]
	VisualServer.set_default_clear_color(table_color)

func _check_table_size():
	var window = OS.get_window_size()

	game_variables.x_size = window.x
	game_variables.y_size = window.y
	
	game_variables.window_size = Vector2(
			ProjectSettings.get("display/window/size/width"),
			ProjectSettings.get("display/window/size/height"))
			
	game_variables.table_size.x = game_variables.window_size.x - 2 * game_variables.BORDER_THICKNESS
	game_variables.table_size.y = round(game_variables.table_size.x / 2)
	
	game_variables.middle_spot_position = Vector2(game_variables.window_size.x / 2, game_variables.window_size.y / 2)
	
	cameraPosition.position.x = game_variables.window_size.x / 2
	cameraPosition.position.y = game_variables.window_size.y / 2
	
	if(window.x * 1.1 > window.y):
		game_variables.orientation = 0
	elif(window.x < window.y * 1.1):
		game_variables.orientation = 1
	else:
		game_variables.orientation = 2
		
func _setup_table():
	# TODO CHECK https://github.com/vrojak/godot-multiplayer-billiards
	#https://www.youtube.com/watch?v=pJ0SW4ayXzU
	border_color = table_color
	border_color.s += BORDER_SATURATION_SHIFT
	
	var top = game_variables.middle_spot_position.y - (game_variables.table_size.y / 2)
	var bottom = game_variables.middle_spot_position.y + (game_variables.table_size.y / 2)
	var left = game_variables.middle_spot_position.x - (game_variables.table_size.x / 2)
	var right = game_variables.middle_spot_position.x + (game_variables.table_size.x / 2)
	
	get_node("Border").get_child(0).set_size(game_variables.table_size.y - 2 * game_variables.CUTOUT_OVERLAP)
	get_node("Border").get_child(0).position = Vector2(left, game_variables.middle_spot_position.y)
	get_node("Border").get_child(2).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(2).position = Vector2((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP + game_variables.BORDER_THICKNESS, top)
	get_node("Border").get_child(4).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(4).position = Vector2(game_variables.table_size.x - ((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP) + game_variables.BORDER_THICKNESS, top)
	get_node("Border").get_child(1).set_size(game_variables.table_size.y - 2 * game_variables.CUTOUT_OVERLAP)
	get_node("Border").get_child(1).position = Vector2(right, game_variables.middle_spot_position.y)
	get_node("Border").get_child(3).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(3).position = Vector2((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP + game_variables.BORDER_THICKNESS, bottom)
	get_node("Border").get_child(5).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(5).position = Vector2(game_variables.table_size.x - ((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP) + game_variables.BORDER_THICKNESS, bottom)
	
	get_node("Holes").get_node("Cutout Corner").position = Vector2(left, top)
	get_node("Holes").get_node("Cutout Corner2").position = Vector2(right, top)
	get_node("Holes").get_node("Cutout Middle2").position = Vector2(game_variables.middle_spot_position.x, top)
	get_node("Holes").get_node("Cutout Corner4").position = Vector2(left, bottom)
	get_node("Holes").get_node("Cutout Corner3").position = Vector2(right, bottom)
	get_node("Holes").get_node("Cutout Middle").position = Vector2(game_variables.middle_spot_position.x, bottom)
	
	for border in get_node("Border").get_children():
		border.set_color(border_color)
		
	for cutout in get_node("Holes").get_children():
		cutout.get_node("Sprite").set_modulate(border_color)
		
	mm_to_px_scaling_factor = game_variables.table_size.x / STANDARD_LENGTH
	ball_radius = round(mm_to_px_scaling_factor * STANDARD_BALL_DIAMETER / 2)
	
	for hole in get_node("Holes").get_children():
		hole.scale.x = mm_to_px_scaling_factor
		hole.scale.y = mm_to_px_scaling_factor
		
	game_variables.head_string_position = game_variables.table_size.x * 3 / 4 # 3/4 of the tables length
	var head_line_top = game_variables.middle_spot_position.y - (game_variables.table_size.y / 2) + ball_radius
	var head_line_bottom = game_variables.middle_spot_position.y + (game_variables.table_size.y / 2) - ball_radius
	HeadString.get_curve().clear_points()
	HeadString.get_curve().add_point(Vector2(game_variables.head_string_position, head_line_top))
	HeadString.get_curve().add_point(Vector2(game_variables.head_string_position, head_line_bottom))
	update() # TODO Remove
	
	game_variables.head_spot_position = Vector2(game_variables.head_string_position, game_variables.middle_spot_position.y)
	game_variables.food_spot_position = Vector2(game_variables.table_size.x * 1 / 4, game_variables.middle_spot_position.y)

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
		var ball = Ball.instance().init(ball_radius, ball_index + 1, colors[ball_index % len(colors)], Vector2(0,0), suit)
		balls.append(ball)
		
	eight_ball = balls[7]
	balls.remove(7)
	
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
			get_node("Balls").add_child(ball)
			assignment_iterator += 1
			
	
func setup_cue_ball():
	self.cue_ball = Ball.instance().init(ball_radius, 0, game_variables.COLORS["white"], game_variables.head_spot_position)
	print(game_variables.head_spot_position)
	
	if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.PlaceBallKitchen:
		var cue_ball_positioner = BallPositioner.instance().init(self.cue_ball)
		self.add_child(cue_ball_positioner)
	else:
		print('Now??')
		get_node("Balls").add_child(self.cue_ball)
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
		var value_to_set = ball.MODE_STATIC if value == true else ball.MODE_RIGID
		ball.set_mode(value_to_set)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_node("InGameMenu").open_pause_menu()
