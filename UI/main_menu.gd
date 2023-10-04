extends Node
## The main menu of the game
##
## Button functionality, switching between menus and changing to the game scene
## is handled here.

const LINK_GITHUB = "https://github.com/danielKlmr/BreakoutShot"
const LINK_MASTODON = "https://mastodon.social/@Daniero"
const MENU_OFFSET_LEFT = 200
const MENU_WIDTH = 512
const TABLE_SCENE_LOCATION = "res://Table/Table.tscn"

@onready var Menu = get_node("Menu")
@onready var SelectItemMenu = Menu.get_node(
		"MenuHMargin/ButtonNode/ButtonTopMargin/SelectItem")
@onready var OptionsMenu = Menu.get_node(
		"MenuHMargin/ButtonNode/ButtonTopMargin/Options")
@onready var InfoMenu = Menu.get_node(
		"MenuHMargin/ButtonNode/ButtonTopMargin/Info")
@onready var InfoBox = InfoMenu.get_node(
		"ScrollContainer/MarginContainer/Label")
@onready var CreditsMenu = Menu.get_node(
		"MenuHMargin/ButtonNode/ButtonTopMargin/Credits")


func _ready():
	_setup_game_version()
	_setup_button_click_sound()
	GameEngine.connect(
			"orientation_changed", Callable(self, "_change_window_orientation"))
	_change_window_orientation(GameEngine.current_orientation)


## Fill in game version to Info menu
func _setup_game_version():
	var version = ProjectSettings.get("application/config/version")
	var VersionLabel = InfoMenu.get_node("VersionAndLinks/VersionLabel")
	VersionLabel.set_text(VersionLabel.get_text() + version)


## Connect every button to play click sound when pressed
func _setup_button_click_sound():
	for button_list in [SelectItemMenu, InfoMenu, CreditsMenu]:
			for button in button_list.get_children():
				if button is Button:
					button.connect("pressed", Callable(self, "_play_click_sound"))


## Plays click sound when button is pressed
func _play_click_sound():
	ClickSound.play()


## Change scene when pressing play
func _on_play_button_pressed():
	get_tree().change_scene_to_file(TABLE_SCENE_LOCATION)


## Change to options menu
func _on_options_button_pressed():
	SelectItemMenu.hide()
	OptionsMenu.show()


## Change to info menu
func _on_info_button_pressed():
	SelectItemMenu.hide()
	InfoMenu.show()


## Change to credits menu
func _on_credits_button_pressed():
	SelectItemMenu.hide()
	CreditsMenu.show()


## Go back to SelectItemsMenu
func _on_back_button_pressed():
	InfoMenu.hide()
	CreditsMenu.hide()
	SelectItemMenu.show()


## Exit game
func _on_quit_button_pressed():
	get_tree().quit()


## Open Github when selecting the link
func _on_github_button_pressed():
	OS.shell_open(LINK_GITHUB)


## Open Mastodon when selecting the link
func _on_mastodon_button_pressed():
	OS.shell_open(LINK_MASTODON)


## Open Website when selecting a link
func _on_link_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at run-time.
	OS.shell_open(str(meta))


## Change menu layout when orientation changes
func _change_window_orientation(
		new_orientation: GameEngine.WindowOrientationModes):
	if new_orientation == GameEngine.WindowOrientationModes.PORTRAIT:
		Menu.set_anchors_preset(Menu.PRESET_VCENTER_WIDE)
		Menu.position.x = int((GameEngine.current_window_size.x / 2.0) - (MENU_WIDTH / 2.0))
	else:
		Menu.set_anchors_preset(Menu.PRESET_LEFT_WIDE)
		Menu.position.x = MENU_OFFSET_LEFT
