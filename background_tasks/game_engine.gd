extends Node
## Engine tasks of the game
##
## Handles tasks that are not related to the logic of the actual game. This
## includes the computation of the current window orientation.

signal orientation_changed(new_orientation)

enum WindowOrientationModes {PORTRAIT, LANDSCAPE}

const LOCATION_MAIN_MENU = "res://ui/main_menu.tscn"
const MINIMUM_WINDOW_SIZE = Vector2i(720, 720)
const STANDARD_MODE_CHANGE_TOLERANCE = 1.1
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

var current_orientation: WindowOrientationModes = WindowOrientationModes.LANDSCAPE
var current_window_size
var original_window_size
var fullscreen: bool
var music = true
# Scalar to balance the intensity of the impulse that is given to a ball
var hit_strength_multiplicator_index = 1


func _ready():
	_setup_window()
	_check_fullscreen()


## Helper function to draw a filled arc polygon
func draw_circle_arc_poly(node, center, arc_radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = []

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(
				angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(
				center + Vector2(cos(angle_point), sin(angle_point)) * arc_radius)
	
	node.draw_colored_polygon(points_arc, color)


## Set original and current window sizes and check orientation mode
func _setup_window():
	# Set original window size, which is the basis for the game scene
	original_window_size = Vector2i(
			ProjectSettings.get("display/window/size/viewport_width"),
			ProjectSettings.get("display/window/size/viewport_height"))
	# Initialize the current window size
	current_window_size = original_window_size
	# Set minimum window size
	DisplayServer.window_set_min_size(MINIMUM_WINDOW_SIZE)
	# Fires when the window size is changed
	get_tree().get_root().connect(
			"size_changed", Callable(self, "_check_window_orientation"))
	# Initially check and set orientation mode when starting the game
	_check_window_orientation(1)


## Check, if game runs in fullscreen and save in variable
func _check_fullscreen():
	fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func _check_window_orientation(
		mode_change_tolerance: float = STANDARD_MODE_CHANGE_TOLERANCE):
	# Find out window orientation
	current_window_size = Vector2(get_viewport().size)
	
	if current_orientation == WindowOrientationModes.LANDSCAPE:
		if current_window_size.x * mode_change_tolerance < current_window_size.y:
			current_orientation = WindowOrientationModes.PORTRAIT
			emit_signal("orientation_changed", current_orientation)
	else:
		if current_window_size.y * mode_change_tolerance < current_window_size.x:
			current_orientation = WindowOrientationModes.LANDSCAPE
			emit_signal("orientation_changed", current_orientation)
