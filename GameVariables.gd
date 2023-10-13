extends Node

const LOCATION_MAIN_MENU = "res://ui/main_menu.tscn"

# Options
var music = true

# Game
var ballradius = 20
var CUTOUT_OVERLAP = 38
var RAIL_SCALE = 0.5
var TABLE_COLORS = [
	Color("mistyrose"),
	Color("wheat"),
	Color("lemonchiffon"),
	Color("lightblue"),
	Color("lavender")]
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
#https://www.reddit.com/r/godot/comments/bp9qsv/visualising_shot_preview_in_2d_snooker_game/

# Scalar to balance the intensity of the impuls that is given to a ball
var HIT_STRENGTH = 5
var hit_strength_multiplicator_index = 1
