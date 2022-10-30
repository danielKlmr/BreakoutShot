extends Node2D

# Singleton
onready var game_variables = get_node("/root/GameVariables")

# Member variables
var balls = []
var table_color
var cue_ball
var eight_ball
var hole_offset = 38
var BORDER_SATURATION_SHIFT = 0.2
onready var GAMEPLAY = get_node("Gameplay")
onready var HeadString = get_node("HeadString")
onready var Ball = preload("res://Ball/Ball.tscn")

func _ready():
	_set_color()
	_check_table_size()
	_setup_table()
	_init_balls()
	GAMEPLAY.play_game(cue_ball)
	
func _draw():
	draw_polyline(HeadString.get_curve().get_baked_points(), game_variables.COLORS["blue"], 2.0)

func _set_color():
	table_color = game_variables.TABLE_COLORS[0]
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
	
	if(window.x * 1.1 > window.y):
		game_variables.orientation = 0
	elif(window.x < window.y * 1.1):
		game_variables.orientation = 1
	else:
		game_variables.orientation = 2
		
func _setup_table():
	var border_color = table_color
	border_color.s += BORDER_SATURATION_SHIFT
	
	get_node("Border").get_child(0).set_size(game_variables.table_size.y - 2 * game_variables.CUTOUT_OVERLAP)
	get_node("Border").get_child(0).position = Vector2(0, game_variables.table_size.y / 2 + game_variables.BORDER_THICKNESS)
	get_node("Border").get_child(2).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(2).position = Vector2((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP + game_variables.BORDER_THICKNESS, 0)
	get_node("Border").get_child(4).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(4).position = Vector2(game_variables.table_size.x - ((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP) + game_variables.BORDER_THICKNESS, 0)
	get_node("Border").get_child(1).set_size(game_variables.table_size.y - 2 * game_variables.CUTOUT_OVERLAP)
	get_node("Border").get_child(1).position = Vector2(game_variables.x_size, game_variables.table_size.y / 2 + game_variables.BORDER_THICKNESS)
	get_node("Border").get_child(3).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(3).position = Vector2((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP + game_variables.BORDER_THICKNESS, game_variables.table_size.y + 2 * game_variables.BORDER_THICKNESS)
	get_node("Border").get_child(5).set_size((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 2)
	get_node("Border").get_child(5).position = Vector2(game_variables.table_size.x - ((game_variables.table_size.x - 4 * game_variables.CUTOUT_OVERLAP) / 4 + game_variables.CUTOUT_OVERLAP) + game_variables.BORDER_THICKNESS, game_variables.table_size.y + 2 * game_variables.BORDER_THICKNESS)
	get_node("Holes").get_node("Cutout Corner4").position = Vector2(0, game_variables.table_size.y + 2 * game_variables.BORDER_THICKNESS)
	get_node("Holes").get_node("Cutout Corner3").position = Vector2(game_variables.window_size.x, game_variables.table_size.y + 2 * game_variables.BORDER_THICKNESS)
	get_node("Holes").get_node("Cutout Middle").position = Vector2(game_variables.window_size.x / 2, game_variables.table_size.y + 2 * game_variables.BORDER_THICKNESS)
	
	for border in get_node("Border").get_children():
		border.set_color(border_color)
		
	for cutout in get_node("Holes").get_children():
		cutout.get_node("Sprite").set_modulate(border_color)
		
	var head_line_x = game_variables.table_size.x * 3 / 4 # 3/4 of the tables length
	var head_line_top = game_variables.BORDER_THICKNESS + game_variables.ballradius
	var head_line_bottom = head_line_top + game_variables.table_size.y - (2 * game_variables.ballradius)
	game_variables.head_string_position = [
		Vector2(head_line_x, head_line_top),
		Vector2(head_line_x, head_line_bottom)
		]
	HeadString.get_curve().clear_points()
	HeadString.get_curve().add_point(game_variables.head_string_position[0])
	HeadString.get_curve().add_point(game_variables.head_string_position[1])
	update() # TODO Remove
	
	game_variables.head_spot_position = Vector2(head_line_x, game_variables.BORDER_THICKNESS + (game_variables.table_size.y / 2))

func _init_balls():
	eight_ball = Ball.instance().init(8, game_variables.COLORS['black'], Vector2(100,100))
	
	var numbers = [5, 13, 15, 6, 12, 11, 7, 14, 4, 10, 8, 3, 9, 2, 1]
	
	var colors = [
		game_variables.COLORS["yellow"],
		game_variables.COLORS["blue"],
		game_variables.COLORS["red"],
		game_variables.COLORS["violet"],
		game_variables.COLORS["orange"],
		game_variables.COLORS["green"],
		game_variables.COLORS["dark_red"],
		game_variables.COLORS["black"]]
		
	for ball_index in game_variables.NUMBER_OBJECT_BALLS:
		var ball = Ball.instance().init(ball_index + 1, colors[ball_index % len(colors)], Vector2(0,0))
		get_node("Balls").add_child(eight_ball)
		balls.append(ball)
		
	eight_ball = balls[9]
	balls.remove(9)
	
	balls.shuffle()
	
	var assignment_iterator = 0
	var distance_rows = game_variables.ballradius * 2 + 7
	var distance_columns = game_variables.ballradius * 2 + 2
	
	for column in range(5):
		var x_position = 150 + column * distance_columns
		for rows in range(5 - column, 0, -1):
			var y_position = (game_variables.y_size / 2) - (((4 - column) * distance_rows) / 2) + (5 - column - rows) * distance_rows 
			_create_ball(Vector2(x_position, y_position), numbers[assignment_iterator], (colors + colors)[numbers[assignment_iterator] - 1])
			assignment_iterator = assignment_iterator + 1
			
	cue_ball = _create_ball(game_variables.head_spot_position, 0, game_variables.COLORS["white"])

# Creates a ball at given position
func _create_ball(position, number, color):
	var new_ball = load("res://Ball/Ball.tscn").instance()
	balls.append(new_ball)
	balls[-1].set_position(position)
	balls[-1].number = number
	balls[-1].color = color
	get_node("Balls").add_child(balls[-1])
	
	return new_ball
	
func delete_ball(ball):
	var ball_number = ball.number
	balls.erase(ball)
	ball.queue_free()
	
	if ball_number == game_variables.EIGHT_BALL_NUMBER:
		get_node("InGameMenu").open_lost_menu()
	
	count_balls()

func count_balls():
	var number_balls = len(balls)
	print(number_balls)
	return number_balls

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_node("InGameMenu").open_pause_menu()
