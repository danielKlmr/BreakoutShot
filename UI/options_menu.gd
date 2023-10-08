extends VBoxContainer
## Options Menu
##
## Handles music and hit strengh while playing

signal go_back()

@onready var FullscreenButton = get_node("FullscreenButton")
@onready var MusicButton = get_node("MusicButton")
@onready var HitStrengthButton = get_node("HitStrengthButton/Button")


func _ready():
	FullscreenButton.set_pressed(GameEngine.fullscreen)
	MusicButton.set_pressed(GameVariables.MUSIC)
	HitStrengthButton.select(
			GameVariables.hit_strength_multiplicator_index)


## Switches between fullscreen and windowed
func _on_fullscreen_button_toggled(button_pressed):
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
	ClickSound.play()
	BackgroundMusic.set_stream_paused(!button_pressed)
	GameVariables.MUSIC = button_pressed


## Set hit strength
func _hit_strength_item_selected(index):
	GameVariables.hit_strength_multiplicator_index = index
