extends Node
## The main menu of the game
##
## Button functionality, switching between menus and changing to the game scene
## is handled here.

@onready var ClickSound = get_node("ClickSound")
@onready var SelectItemMenu = get_node(
		"Menu/MenuItems/ButtonNode/ButtonMarginContainer/SelectItem")
@onready var OptionsMenu = get_node(
		"Menu/MenuItems/ButtonNode/ButtonMarginContainer/Options")
@onready var InfoMenu = get_node(
		"Menu/MenuItems/ButtonNode/ButtonMarginContainer/Info")
@onready var InfoBox = get_node(
		"Menu/MenuItems/ButtonNode/ButtonMarginContainer/Info/ScrollContainer/MarginContainer/Label")
@onready var CreditsMenu = get_node(
		"Menu/MenuItems/ButtonNode/ButtonMarginContainer/Credits")


func _ready():
	_setup_game()
	_setup_main_menu()
	for button_list in [SelectItemMenu, InfoMenu, CreditsMenu]:
		for button in button_list.get_children():
			if button is Button:
				button.connect("pressed", Callable(self, "_play_click_sound"))
	OptionsMenu.get_node("MusicButton").set_pressed(GameVariables.MUSIC)


func _setup_game():
	DisplayServer.window_set_min_size(GameVariables.MINIMUM_WINDOW_SIZE)


func _setup_main_menu():
	var version = ProjectSettings.get("application/config/version")
	var VersionLabel = InfoMenu.get_node("VersionLabel")
	VersionLabel.set_text(VersionLabel.get_text() + version)


func _play_click_sound():
	ClickSound.play()


func _on_Button_pressed():
	get_tree().change_scene_to_file("res://Table/Table.tscn")


func _on_InfoButton_pressed():
	SelectItemMenu.hide()
	InfoMenu.show()


func _on_CreditsButton_pressed():
	SelectItemMenu.hide()
	CreditsMenu.show()


func _on_BackButton_pressed():
	OptionsMenu.hide()
	InfoMenu.hide()
	CreditsMenu.hide()
	SelectItemMenu.show()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_link_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at run-time.
	OS.shell_open(str(meta))


func _on_music_button_toggled(button_pressed):
	BackgroundMusic.set_stream_paused(!button_pressed)
	GameVariables.MUSIC = button_pressed


func _on_options_button_pressed():
	SelectItemMenu.hide()
	OptionsMenu.show()
