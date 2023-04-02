extends Node

@onready var ClickSound = get_node("ClickSound")
@onready var SelectItemMenu = get_node("MarginContainer/MarginContainer/SelectItem")
@onready var InfoMenu = get_node("MarginContainer/MarginContainer/Info")
@onready var InfoBox = get_node("MarginContainer/MarginContainer/Info/ScrollContainer/MarginContainer/Label")
@onready var CreditsMenu = get_node("MarginContainer/MarginContainer/Credits")


func _ready():
	for button_list in [SelectItemMenu, InfoMenu, CreditsMenu]:
		for button in button_list.get_children():
			if button is Button:
				button.connect("pressed", Callable(self, "_play_click_sound"))

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
