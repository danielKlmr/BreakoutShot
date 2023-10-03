extends VBoxContainer
## Options Menu
##
## Handles music and hit strengh while playing

signal go_back()


func _on_back_button_pressed():
	ClickSound.play()
	self.hide()
	emit_signal("go_back")


func _on_music_button_toggled(button_pressed):
	ClickSound.play()
	BackgroundMusic.set_stream_paused(!button_pressed)
	GameVariables.MUSIC = button_pressed


func _hit_strength_item_selected(index):
	GameVariables.hit_strength_multiplicator_index = index
