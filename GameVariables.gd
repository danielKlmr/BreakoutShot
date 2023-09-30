extends Node

# Technical
var SNAPPING_DISTANCE = 50
var MINIMUM_WINDOW_SIZE = Vector2i(720, 720)
var HUD_PADDING = 30
var hud_height = null

# Options
var MUSIC = true

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

var window_size = Vector2i(1920, 1080)
var table_size = Vector2(0, 0)
var ballradius = 20
var BORDER_THICKNESS = 70
var CUTOUT_OVERLAP = 38
var BORDER_SCALE = 0.5
var OUTSIDE_DRAWING = 5000 # How much should be drawn outside of the intended window
const COLORS = {
	"white": Color(0.9, 0.9, 0.9, 1),
	"black": Color(0.29, 0.29, 0.29, 1),
	"yellow": Color(0.85, 0.74, 0.4, 1),
	"violet": Color(0.63, 0.49, 0.72, 1),
	"blue": Color(0.45, 0.47, 0.9, 1),
	"red": Color(0.78, 0.32, 0.33, 1),
	"orange": Color(0.94, 0.54, 0.36, 1),
	"green": Color(0.49, 0.62, 0.3, 1),
	"dark_red": Color(0.72, 0.23, 0.36, 1),
}
"""const COLORS = {
	"white": Color(0.75, 0.75, 0.75, 1),
	"black": Color(0.15, 0.15, 0.15, 1),#
	"yellow": Color(0.85, 0.65, 0.28, 1),#
	"violet": Color(0.71, 0.22, 0.82, 1),#
	"blue": Color(0.2, 0.35, 0.71, 1),#
	"red": Color(0.78, 0.27, 0.38, 1),#
	"orange": Color(0.66, 0.3, 0.19, 1),#
	"green": Color(0.11, 0.35, 0.17, 1),#
	"dark_red": Color(0.55, 0.2, 0.23, 1),#
}"""
var TABLE_COLORS = [
	Color("mistyrose"),
	Color("wheat"),
	Color("lemonchiffon"),
	Color("lightblue"),
	Color("lavender")]
#https://www.reddit.com/r/godot/comments/bp9qsv/visualising_shot_preview_in_2d_snooker_game/

var EIGHT_BALL_NUMBER = 8
