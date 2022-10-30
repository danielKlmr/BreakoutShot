extends Node


func _ready():
	pass # Replace with function body.



func _on_Button4_pressed():
	get_tree().quit()


func _on_Button_pressed():
	get_tree().change_scene("res://Table/Table.tscn")


func _on_BackToMenuButton_pressed():
	print("clicked")
	get_tree().change_scene("res://UI/Main Menu.tscn")


func _on_ContinueButton_pressed():
	get_parent().hide()


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()
