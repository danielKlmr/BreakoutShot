extends Node

# Technical
var SNAPPING_DISTANCE = 50

# Table
var x_size = 0
var y_size = 0
var middle_spot_position = null
var head_string_position = null
var head_spot_position = null
var food_spot_position = null

# Game
var NUMBER_OBJECT_BALLS = 15

# Statics
enum suits {Stripe, Solid}

var window_size = Vector2(0, 0)
var table_size = Vector2(0, 0)
var ballradius = 20
var orientation = 0 # 0 = Landscape, 1 = Portrait, 2 = (Almost) square
var BORDER_THICKNESS = 70
var CUTOUT_OVERLAP = 38
var BORDER_SCALE = 0.5
var OUTSIDE_DRAWING = 5000 # How much should be drawn outside of the intended window
const COLORS = {
	"yellow": Color(0.89, 0.87, 0.53, 1),
	"violet": Color(0.63, 0.49, 0.72, 1),
	"white": Color(0.9, 0.9, 0.9, 1),
	"black": Color(0.29, 0.29, 0.29, 1),
	"blue": Color(0.45, 0.47, 0.9, 1),
	"red": Color(0.72, 0.23, 0.36, 1),
	"orange": Color(0.94, 0.54, 0.36, 1),
	"green": Color(0.49, 0.62, 0.3, 1),
	"dark_red": Color(0.72, 0.23, 0.36, 1),
}
var TABLE_COLORS = [
	Color("mistyrose"),
	Color("wheat"),
	Color("lemonchiffon"),
	Color("lightblue"),
	Color("lavender")]
#https://www.reddit.com/r/godot/comments/bp9qsv/visualising_shot_preview_in_2d_snooker_game/

var EIGHT_BALL_NUMBER = 8
