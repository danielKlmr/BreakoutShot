extends Node2D
## Table Scene
##
## Game scene that holds the playing surface and ingame GUI

const HUD_PADDING = 30

var _camera_zoom = 1
var _hud_height

@onready var gameplay = get_node("Gameplay")
@onready var playing_surface = get_node("PlayingSurface")
@onready var camera = get_node("PlayingSurface/Camera3D")
@onready var gui = get_node("GUI Layer")
@onready var hud = gui.get_node("HUD")


func _ready():
	_setup_window()
	_setup_gui()
	_setup_playing_surface()
	_update_camera()
	gameplay.set_game_state(gameplay.GameStates.START)


## Get signals when window size or orientation changes
func _setup_window():
	get_tree().get_root().connect(
			"size_changed", Callable(self, "_update_camera"))
	GameEngine.connect(
			"orientation_changed", Callable(self, "_change_table_orientation"))


## Set height of the hud and scale camera to fit the screen
func _setup_gui():
	_hud_height = hud.get_size().y + HUD_PADDING
	# Offset is only half of hud height because playing surface is scaled to
	# window withoud hud. Therefore, half of the hud size is already free at top
	# and bottom
	camera.offset.y = -_hud_height / 2
	gameplay.connect("place_cue_ball", Callable(gui, "show_place_cue"))
	gameplay.connect("increase_attempts", Callable(gui, "increase_attempts"))
	gameplay.connect("foul", Callable(gui, "foul"))
	gameplay.connect("lost", Callable(gui, "open_lost_menu"))
	gameplay.connect("win", Callable(gui, "open_win_menu"))


## Set playing surface position
func _setup_playing_surface():
	playing_surface.set_position(GameEngine.original_window_size / 2)
	gameplay.connect("play", Callable(playing_surface, "play"))
	playing_surface.connect("strike_object_ball", Callable(gameplay, "strike_object_ball"))


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
	
	camera.set_zoom(Vector2(_camera_zoom, _camera_zoom))


## Change table orientation if signal to do so is received
func _change_table_orientation(
		new_orientation: GameEngine.WindowOrientationModes):
	if new_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		playing_surface.set_rotation(PI/2)
	else:
		playing_surface.set_rotation(0)
