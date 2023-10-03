extends Node
## The main menu of the game
##
## Button functionality, switching between menus and changing to the game scene
## is handled here.

const MENU_OFFSET_LEFT = 200

@onready var Menu = get_node("Menu")
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
	_setup_main_menu()
	GameEngine.connect(
			"orientation_changed", Callable(self, "_change_window_orientation"))
	for button_list in [SelectItemMenu, InfoMenu, CreditsMenu]:
		for button in button_list.get_children():
			if button is Button:
				button.connect("pressed", Callable(self, "_play_click_sound"))
	OptionsMenu.get_node("MusicButton").set_pressed(GameVariables.MUSIC)


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
	InfoMenu.hide()
	CreditsMenu.hide()
	SelectItemMenu.show()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_link_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at run-time.
	OS.shell_open(str(meta))


func _on_options_button_pressed():
	SelectItemMenu.hide()
	OptionsMenu.show()

func _change_window_orientation(
		new_orientation: GameEngine.WindowOrientationModes):
	if new_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		Menu.set_anchors_preset(Menu.PRESET_VCENTER_WIDE)
		Menu.position.x = GameEngine.current_window_size.x / 2 - 256 # TODO
	else:
		Menu.set_anchors_preset(Menu.PRESET_LEFT_WIDE)
		Menu.position.x = MENU_OFFSET_LEFT
