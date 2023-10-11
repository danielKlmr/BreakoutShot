extends VBoxContainer
## Options Menu
##
## Handles music and hit strengh while playing

signal go_back()

var pressed_by_user = false

@onready var fullscreen_button = get_node("FullscreenButton")
@onready var music_button = get_node("MusicButton")
@onready var hit_strength_button = get_node("HitStrengthButton/Button")


func _ready():
	fullscreen_button.set_pressed(GameEngine.fullscreen)
	music_button.set_pressed(GameVariables.music)
	hit_strength_button.select(
			GameVariables.hit_strength_multiplicator_index)
	pressed_by_user = true


## Switches between fullscreen and windowed
func _on_fullscreen_button_toggled(button_pressed):
	if pressed_by_user:
		ClickSound.play()
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	GameEngine.fullscreen = button_pressed


## Hide menu and emit signal when back button is pressed
func _on_back_button_pressed():
	ClickSound.play()
	self.hide()
	emit_signal("go_back")


## Turn background music on or off
func _on_music_button_toggled(button_pressed):
	if pressed_by_user:
		ClickSound.play()
	BackgroundMusic.set_stream_paused(!button_pressed)
	GameVariables.music = button_pressed


## Set hit strength
func _hit_strength_item_selected(index):
	if pressed_by_user:
		ClickSound.play()
	GameVariables.hit_strength_multiplicator_index = index
