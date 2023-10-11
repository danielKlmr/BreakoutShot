extends CanvasLayer
## Ingame GUI
##
## Handles ingame menu and HUD

const AUTOCLOSE_TIME = 2.0

@onready var popup = get_node("Popup")
@onready var popup_elements = popup.get_node("PopupElements")
@onready var label = popup.get_node("PopupElements/LabelMargin/LabelVBox/Label")
@onready var subtext = popup.get_node(
		"PopupElements/LabelMargin/LabelVBox/Subtext")
@onready var popup_menu = popup.get_node("PopupElements/PopupMenu")
@onready var win_lost_buttons = popup.get_node("PopupElements/WinLostButtons")
@onready var options_menu = popup.get_node("PopupElements/OptionsMenu")
@onready var attempts_value = get_node("HUD/Stats/Attempts Value")
@onready var fouls_value = get_node("HUD/Stats/Fouls Value")


func _ready():
	_close_popup()
	attempts_value.set_text(str(0))
	fouls_value.set_text(str(0))


func _unhandled_input(event):
	# Open pause menu
	if (
			event is InputEventKey
			and event.is_pressed()
			and event.keycode == KEY_ESCAPE
	):
		_toggle_pause_menu()


## Show popup with given title
func _open_popup(title):
	label.set_text(title)
	popup.show()


## Hide popup
func _close_popup():
	# Unpause if game is paused
	get_tree().paused = false
	subtext.hide()
	popup_menu.hide()
	win_lost_buttons.hide()
	options_menu.hide()
	popup.hide()


## Toggle pause menu
func _toggle_pause_menu():
	ClickSound.play()
	if !get_tree().is_paused():
		subtext.hide()
		popup_menu.show()
		get_tree().paused = true
		_open_popup("Pause")
	else:
		_close_popup()


## Show win popup
func open_win_menu():
	win_lost_buttons.show()
	_open_popup("Won!")

## Show lost popup
func open_lost_menu():
	win_lost_buttons.show()
	_open_popup("Lost!")


## Popup to show when ball has to be placed
func show_place_cue():
	_open_popup("Place\nCue Ball!")
	
	await get_tree().create_timer(AUTOCLOSE_TIME).timeout
	if !get_tree().is_paused():
		_close_popup()


## Set attempts value when signal is received
func hit_ball(number_attempts):
	attempts_value.set_text(str(number_attempts))


## Set fouls value when signal is received and open foul popup
func foul(number_fouls):
	fouls_value.set_text(str(number_fouls))
	
	subtext.show()
	subtext.set_text('Place Cue Ball in Head Field')
	_open_popup("Foul!")
	
	await get_tree().create_timer(AUTOCLOSE_TIME).timeout
	if !get_tree().is_paused():
		_close_popup()


## Change scene to main menu
func _on_BackToMenuButton_pressed():
	ClickSound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file(GameVariables.LOCATION_MAIN_MENU)


## Reload table scene
func _on_RestartButton_pressed():
	ClickSound.play()
	get_tree().paused = false
	get_tree().reload_current_scene()


## Show options menu
func _on_options_button_pressed():
	ClickSound.play()
	popup_menu.hide()
	options_menu.show()


## Go back to popup menu
func _on_back_button_pressed():
	options_menu.hide()
	popup_menu.show()
