extends Node2D
## Table Scene
##
## Game scene that holds the playing surface and ingame GUI

const HUD_PADDING = 30

var _camera_zoom = 1
var _hole_offset = 38
var _hud_height

@onready var Gameplay = get_node("Gameplay")
@onready var PlayingSurface = get_node("PlayingSurface")
@onready var Camera = get_node("PlayingSurface/Camera3D")
@onready var GUI = get_node("GUI Layer/HUD")


func _ready():
	_setup_window()
	_setup_gui()
	_setup_playing_surface()
	_update_camera()
	Gameplay.set_game_state(Gameplay.game_states.Start)


## Get signals when window size or orientation changes
func _setup_window():
	get_tree().get_root().connect(
			"size_changed", Callable(self, "_update_camera"))
	GameEngine.connect(
			"orientation_changed", Callable(self, "_change_table_orientation"))


## Set height of the hud and scale camera to fit the screen
func _setup_gui():
	_hud_height = GUI.get_size().y + HUD_PADDING
	# Offset is only half of hud height because playing surface is scaled to
	# window withoud hud. Therefore, half of the hud size is already free at top
	# and bottom
	Camera.offset.y = -_hud_height / 2


## Set playing surface position
func _setup_playing_surface():
	PlayingSurface.set_position(GameEngine.original_window_size / 2)


## Manual scales canvas items to window size, so that UI elements can stay the
## same size when window size is changed. Therefore, stretch mode is disabled.
func _update_camera():
	var original_size = Vector2(GameEngine.original_window_size)
	if GameEngine.current_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		original_size = Vector2(GameEngine.original_window_size.y, GameEngine.original_window_size.x)
	var current_window_height_without_hud = GameEngine.current_window_size.y - _hud_height
	
	var x_scale = GameEngine.current_window_size.x / original_size.x
	var y_scale = current_window_height_without_hud / original_size.y
	
	_camera_zoom = min(x_scale, y_scale)
	
	Camera.set_zoom(Vector2(_camera_zoom, _camera_zoom))


	

func _change_table_orientation(
		new_orientation: GameEngine.WindowOrientationModes):
	if new_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		PlayingSurface.set_rotation(PI/2)
	else:
		PlayingSurface.set_rotation(0)
	

	
func set_balls_static(value: bool):
	for ball in PlayingSurface._balls:
		ball.set_freeze_enabled(value)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_node("GUI Layer").open_pause_menu()
			
func convert_global_position_to_scaled_position(position_global:Vector2i):
	var position_scaled = Vector2i(position_global / _camera_zoom)
	#var position_scaled = get_viewport().get_viewport_transform() * Vector2(position_global)
	
	return position_scaled
