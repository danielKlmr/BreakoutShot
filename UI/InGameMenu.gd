extends CanvasLayer

var AUTOCLOSE_TIME = 2.0

@onready var vbox = self.get_node("InGameMenu/VBoxContainer")
@onready var label = self.get_node("InGameMenu/VBoxContainer/Label")
@onready var subtext = self.get_node("InGameMenu/VBoxContainer/Subtext")
@onready var InGameMenu = $InGameMenu
@onready var OptionsMenu = get_node("InGameMenu/OptionsMenu")
@onready var buttons = {
	"menu": get_node("HUD/Stats/MenuButton"),
	"continue": vbox.get_node("ContinueButton"),
	"restart": vbox.get_node("RestartButton"),
	"back_to_menu": vbox.get_node("BackToMenuButton"),
	"options": vbox.get_node("OptionsButton")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_close_popup()
	for button in buttons.values():
		button.connect("pressed", Callable(self, "_play_click_sound"))
		
func _play_click_sound():
	$ClickSound.play()
	
func _open_popup(title):
	# TODO: If not already open
	label.set_text(title)
	InGameMenu.show()
	buttons["menu"].hide() # TODO: Hide only when pause menu is open, not notification
	
func _close_popup():
	subtext.hide()
	for button in buttons.values():
		button.hide()
	InGameMenu.hide()
	buttons["menu"].show()

func open_pause_menu():
	buttons['continue'].show()
	buttons['restart'].show()
	buttons['back_to_menu'].show()
	buttons['options'].show()
	get_tree().paused = true
	_open_popup("Pause")
	
func open_win_menu():
	InGameMenu.buttons['restart'].show()
	InGameMenu.buttons['back_to_menu'].show()
	_open_popup("Won!")
	
func open_lost_menu():
	buttons['restart'].show()
	buttons['back_to_menu'].show()
	_open_popup("Lost!")

func show_place_cue():
	print("calleb")
	_open_popup("Place Cue Ball!")
	await get_tree().create_timer(AUTOCLOSE_TIME).timeout
	_close_popup()
	
func show_foul():
	subtext.show()
	subtext.set_text('Place Cue Ball in Head Field')
	_open_popup("Foul!")
	await get_tree().create_timer(AUTOCLOSE_TIME).timeout
	_close_popup()

func _on_BackToMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_ContinueButton_pressed():
	get_tree().paused = false
	_close_popup()


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_options_button_pressed():
	vbox.hide()
	OptionsMenu.show()


func _on_back_button_pressed():
	OptionsMenu.hide()
	vbox.show()
