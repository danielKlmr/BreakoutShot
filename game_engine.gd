extends Node
## Engine tasks of the game
##
## Handles tasks that are not related to the logic of the actual game. This
## includes the computation of the current window orientation.

signal orientation_changed(new_orientation)

enum WindowOrientationModes {PORTRAIT, LANDSCAPE}

const MINIMUM_WINDOW_SIZE = Vector2i(720, 720)
const STANDARD_MODE_CHANGE_TOLERANCE = 1.1

var current_orientation: WindowOrientationModes = WindowOrientationModes.LANDSCAPE
var current_window_size
var original_window_size


func _ready():
	_setup_window()


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
