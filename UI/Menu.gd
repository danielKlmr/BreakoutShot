extends Node

onready var SelectItemMenu = get_node("MarginContainer/MarginContainer/SelectItem")
onready var InfoMenu = get_node("MarginContainer/MarginContainer/Info")
onready var InfoBox = get_node("MarginContainer/MarginContainer/Info/ScrollContainer/Label")

func _ready():
	pass # Replace with function body.

func load_text(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	return content

func _on_Button_pressed():
	get_tree().change_scene("res://Table/Table.tscn")


func _on_BackToMenuButton_pressed():
	get_tree().change_scene("res://UI/Main Menu.tscn")

func _on_ContinueButton_pressed():
	get_parent().hide()

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_InfoButton_pressed():
	SelectItemMenu.hide()
	InfoMenu.show()
	var infotext = load_text("res://UI/Infotext.txt")
	InfoBox.set_text(infotext)

func _on_BackButton_pressed():
	InfoMenu.hide()
	SelectItemMenu.show()


func _on_QuitButton_pressed():
	get_tree().quit()
