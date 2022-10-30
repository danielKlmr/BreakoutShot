extends Popup



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _open_popup(title):
	# TODO: If not already open
	self.get_node("VBoxContainer/Label").set_text(title)
	self.popup()

func open_pause_menu():
	_open_popup("Pause")
	
func open_win_menu():
	self.get_node("VBoxContainer/ContinueButton").hide()
	_open_popup("Won!")
	
func open_lost_menu():
	self.get_node("VBoxContainer/ContinueButton").hide()
	_open_popup("Lost!")

func show_place_cue():
	pass # TODO
