extends Node2D
## Playing Surface
##
## Holding the tables rails, holes, balls and the camera

signal ball_removed(ball_number: int, number_object_balls: int)

const NUMBER_OBJECT_BALLS = 15
const EIGHT_BALL_NUMBER = 8
const NUMBER_BALL_COLUMNS = 5
const RACK_BALL_OFFSET_ROWS = 3
const RACK_BALL_OFFSET_COLUMNS = -1
const RAIL_COLOR_SHIFT = 0.2
const RAIL_SATURATION_SHIFT = -0.1
const COLORS_TABLE = [
	"yellow",
	"violet",
	"blue",
	"red",
	"orange",
	"green",
	"dark_red",
]
const SPOT_DRAWING_SIZE = 5
const SNAPPING_DISTANCE = 50
# Field size (mm)
# https://de.wikipedia.org/wiki/Billardtisch_(Pool)
const POCKET_NODE_SIZE = 256
const STANDARD_BALL_DIAMETER = 57.2
const STANDARD_LENGTH = 2240
const STANDARD_WIDTH = 1120

var head_spot_position: Vector2i
var center_spot_position = Vector2i(0, 0)
var foot_spot_position: Vector2i
var head_string_x_position

var _balls = []
var _cue_ball
var _eight_ball
var _cue_ball_positioner
var _number_object_balls
var _ball_radius
var _rail_color
var _mm_to_px_scaling_factor
# How much of the corner pocket is part of the rail
var _pocket_node_overlap
var _table_color
var _table_size: Vector2i

@onready var Ball = preload("res://Ball/Ball.tscn")
@onready var CueBall = preload("res://Ball/CueBall.tscn")
@onready var BallPositioner = preload("res://Ball/BallPositioner.tscn")
@onready var Balls = get_node("Balls")
@onready var HeadString = get_node("HeadString")
@onready var Pockets = get_node("Pockets")
@onready var Rails = get_node("Rails")


func _ready():
	_set_table_color()
	_setup_table_size()
	_convert_mm_to_px()
	_setup_table()
	_setup_play_field()
	_init_balls()
	setup_cue_ball(false)


func _draw():
	# Draw the brighter background of the playing surface
	var background_size = GameEngine.original_window_size
	if GameEngine.current_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		background_size = Vector2i(background_size.y, background_size.x)
	draw_rect(Rect2(
			-(GameEngine.original_window_size / 2), GameEngine.original_window_size),
			_table_color)
	
	# Draw spots on playing surface
	draw_circle(foot_spot_position, SPOT_DRAWING_SIZE, _rail_color)
	draw_circle(head_spot_position, SPOT_DRAWING_SIZE, _rail_color)
	draw_circle(center_spot_position, SPOT_DRAWING_SIZE, _rail_color)


## Place cue ball in head field
## If kitchen is true, the cue ball is placed in the kitchen, otherwise it is
## placed on the head string
func setup_cue_ball(kitchen):
	# Remove cue ball if it already exists (in case of foul)
	if _cue_ball:
		delete_ball(_cue_ball, false)
	var Gameplay = get_parent().get_node("Gameplay")
	_cue_ball = CueBall.instantiate().init(
			_ball_radius,
			0,
			GameVariables.COLORS["white"],
			head_spot_position)
	randomize()
	_cue_ball.set_rotation(randf_range(0, 2*PI))
	
	if kitchen:
		_cue_ball_positioner = BallPositioner.instantiate().init(_cue_ball)
		add_child(_cue_ball_positioner)
	else:
		Balls.add_child(_cue_ball)


## Use mouse position to project the cue ball to the head string
func project_cue_ball_to_head_string():
	var mouse_position = get_local_mouse_position()
	var projected_position = HeadString.get_curve().get_closest_point(mouse_position)
	
	# Check if projected position is in snapping distance to head spot
	var vector_to_head_spot = projected_position - Vector2(head_spot_position)
	if vector_to_head_spot.length() < SNAPPING_DISTANCE:
		_cue_ball.set_position(head_spot_position)
	else:
		_cue_ball.set_position(projected_position)


# Klicking in the kitchen while placing the cue ball removes the ball positioner
# and activates the cue ball
func place_cue_ball_in_kitchen():
	var cue_ball_position = _cue_ball_positioner.get_position()
	_cue_ball.set_position(cue_ball_position)
	_cue_ball.get_node("CollisionShape2D").set_disabled(false)
	_cue_ball.set_freeze_enabled(false)
	_cue_ball_positioner.remove_child(_cue_ball)
	Balls.add_child(_cue_ball)
	_cue_ball_positioner.queue_free()
	get_parent().set_balls_static(false) # TODO move


## Delete a given ball
func delete_ball(ball, in_pocket = true):
	var ball_number = ball.number
	_balls.erase(ball)
	ball.queue_free()
	
	_count_object_balls()
	
	if in_pocket:
		emit_signal("ball_removed", ball_number, _number_object_balls)
	
	if ball_number == 0:
		_cue_ball = null


## Set the colors of the table rails and the playing surface
func _set_table_color():
	randomize()
	var color_index:int = randi() % len(COLORS_TABLE)
	var color_name = COLORS_TABLE[color_index]
	_rail_color = GameVariables.COLORS[color_name]
	
	_table_color = _rail_color
	_table_color.s += RAIL_SATURATION_SHIFT
	_table_color.r += RAIL_COLOR_SHIFT
	_table_color.g += RAIL_COLOR_SHIFT
	_table_color.b += RAIL_COLOR_SHIFT
	
	RenderingServer.set_default_clear_color(_rail_color)


## Calculate the size of the table in pixels in landscape mode
func _setup_table_size():
	var table_length = GameEngine.original_window_size.x - (2 * GameVariables.RAIL_THICKNESS)
	_table_size = Vector2i(
			table_length,
			round(table_length / 2))


## Standard sizes given in mm are converted to pixel sizes
func _convert_mm_to_px():
	_mm_to_px_scaling_factor = float(_table_size.x) / STANDARD_LENGTH
	
	for hole in Pockets.get_children():
		hole.set_scale(
				Vector2(_mm_to_px_scaling_factor, _mm_to_px_scaling_factor))
		_pocket_node_overlap = floor(
				POCKET_NODE_SIZE * _mm_to_px_scaling_factor / 2)
	
	_ball_radius = round(_mm_to_px_scaling_factor * STANDARD_BALL_DIAMETER / 2)


## Set pocket and rail locations
## Position of corners: Half of the table size in each direction for corners
func _setup_table():
	var top = -(_table_size.y / 2)
	var bottom = (_table_size.y / 2)
	var left = -(_table_size.x / 2)
	var right = (_table_size.x / 2)
	
	Rails.get_node("Rail TL").set_position(Vector2(
			-(_table_size.x - 4 * _pocket_node_overlap) / 4 - _pocket_node_overlap,
			top))
	Rails.get_node("Rail TR").set_position(Vector2(
			((_table_size.x - 4 * _pocket_node_overlap) / 4 + _pocket_node_overlap),
			top))
	Rails.get_node("Rail BL").set_position(Vector2(
			-(_table_size.x - 4 * _pocket_node_overlap) / 4 - _pocket_node_overlap,
			bottom))
	Rails.get_node("Rail BR").set_position(Vector2(
			((_table_size.x - 4 * _pocket_node_overlap) / 4 + _pocket_node_overlap),
			bottom))

	Rails.get_node("Rail L").set_size(
			_table_size.y - 2 * _pocket_node_overlap)
	Rails.get_node("Rail TL").set_size(
			(_table_size.x - 4 * _pocket_node_overlap) / 2)
	Rails.get_node("Rail TR").set_size(
			(_table_size.x - 4 * _pocket_node_overlap) / 2)
	Rails.get_node("Rail R").set_size(
			_table_size.y - 2 * _pocket_node_overlap)
	Rails.get_node("Rail BL").set_size(
			(_table_size.x - 4 * _pocket_node_overlap) / 2)
	Rails.get_node("Rail BR").set_size(
			(_table_size.x - 4 * _pocket_node_overlap) / 2)
	
	for rail in Rails.get_children():
		rail.set_color(_rail_color)
		
	for pocket in get_node("Pockets").get_children():
		pocket.get_node("Surface").set_modulate(_rail_color)


## Setup headstring, headspot and footspot
func _setup_play_field():
	# Head spot is at 3/4 of the tables length, foot spot at 1/4
	head_spot_position = Vector2(_table_size.x * 1 / 4, 0)
	foot_spot_position = Vector2(-_table_size.x * 1 / 4, 0)
	
	# Headstring
	head_string_x_position = head_spot_position.x
	var head_line_top = -(_table_size.y / 2) + _ball_radius
	var head_line_bottom = (_table_size.y / 2) - _ball_radius
	HeadString.get_curve().clear_points()
	HeadString.get_curve().add_point(Vector2(
			head_string_x_position, head_line_top))
	HeadString.get_curve().add_point(Vector2(
			head_string_x_position, head_line_bottom))


## Instantiate and position object balls
func _init_balls():
	var ball_colors = ["yellow", "blue", "red", "violet", "orange", "green",
		"dark_red", "black"]
	
	for ball_index in NUMBER_OBJECT_BALLS:
		# Define color
		var color = GameVariables.COLORS[ball_colors[ball_index % len(ball_colors)]]
		# Instantiate ball
		var ball = Ball.instantiate().init(
				_ball_radius,
				ball_index + 1,
				color,
				Vector2(0,0))
		# Define suit
		if ball_index < EIGHT_BALL_NUMBER:
			ball.suit = ball.Suits.Solid
		else:
			ball.suit = ball.Suits.Stripe
		# Eight ball is assigned to another variable and not part of the list yet
		if ball_index == EIGHT_BALL_NUMBER - 1:
			_eight_ball = ball
		else:
			_balls.append(ball)
	
	# Shuffle ball order and make corner balls of different suit
	randomize()
	_balls.shuffle()
	if _balls[-5].suit == _balls[-1].suit:
		for ball_number in range(NUMBER_OBJECT_BALLS - 1):
			var ball = _balls[ball_number]
			if ball.suit != _balls[-1].suit:
				_balls.erase(ball)
				_balls.insert(NUMBER_OBJECT_BALLS - 6, ball)
				break
	
	# Insert eight ball in list
	# Insert always after the given index
	_balls.insert(4, _eight_ball)
	
	# Place balls
	var assignment_iterator = 0
	var distance_rows = _ball_radius * 2 + RACK_BALL_OFFSET_ROWS
	var distance_columns = _ball_radius * 2 + RACK_BALL_OFFSET_COLUMNS
	# Place from the front column to the rear column
	for column in range(NUMBER_BALL_COLUMNS):
		var x_position = foot_spot_position.x - (column * distance_columns)
		var lowest_y_position = foot_spot_position.y - ((column * distance_rows) / 2)
		for rows in range(0, column+1):
			var y_position = lowest_y_position + (rows * distance_rows) 
			var ball = _balls[assignment_iterator]
			ball.set_position(Vector2(x_position, y_position))
			ball.set_rotation(randf_range(0, 2*PI))
			Balls.add_child(ball)
			assignment_iterator += 1
	
	_count_object_balls()


## Count the number of object balls
func _count_object_balls():
	_number_object_balls = len(_balls)
