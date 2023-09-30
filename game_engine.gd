extends Node
## Engine tasks of the game
##
## Handles tasks that are not related to the logic of the actual game. This
## includes the computation of the current window orientation.

signal orientation_changed(new_orientation)

enum WindowOrientationModes {PORTRAIT, LANDSCAPE}

var current_orientation: WindowOrientationModes = WindowOrientationModes.LANDSCAPE
var current_window_size = Vector2i(1920, 1080)


func _process(_delta):
	_find_out_window_orientation()


func _find_out_window_orientation():
	var mode_change_tolerance = 1.1
	
	if current_orientation == WindowOrientationModes.LANDSCAPE:
		if current_window_size.x * mode_change_tolerance < current_window_size.y:
			current_orientation = WindowOrientationModes.PORTRAIT
			emit_signal("orientation_changed", current_orientation)
	else:
		if current_window_size.y * mode_change_tolerance < current_window_size.x:
			current_orientation = WindowOrientationModes.LANDSCAPE
			emit_signal("orientation_changed", current_orientation)
