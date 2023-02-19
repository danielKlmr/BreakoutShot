extends Popup

var AUTOCLOSE_TIME = 2.0

onready var vbox = self.get_node("VBoxContainer")
onready var label = self.get_node("VBoxContainer/Label")
onready var subtext = self.get_node("VBoxContainer/Subtext")
onready var buttons = {
	"continue": vbox.get_node("ContinueButton"),
	"restart": vbox.get_node("RestartButton"),
	"back_to_menu": vbox.get_node("BackToMenuButton"),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_close_popup()
	
func _open_popup(title):
	# TODO: If not already open
	label.set_text(title)
	self.popup()
	
func _close_popup():
	subtext.hide()
	for button in buttons.values():
		button.hide()
	self.hide()

func open_pause_menu():
	self.buttons['continue'].show()
	self.buttons['restart'].show()
	self.buttons['back_to_menu'].show()
	_open_popup("Pause")
	
func open_win_menu():
	self.buttons['restart'].show()
	self.buttons['back_to_menu'].show()
	_open_popup("Won!")
	
func open_lost_menu():
	self.buttons['restart'].show()
	self.buttons['back_to_menu'].show()
	_open_popup("Lost!")

func show_place_cue():
	_open_popup("Place Cue Ball!")
	yield(get_tree().create_timer(AUTOCLOSE_TIME), "timeout")
	_close_popup()
	
func show_foul():
	subtext.show()
	subtext.set_text('Place Cue Ball in Head Field')
	_open_popup("Foul!")
	yield(get_tree().create_timer(AUTOCLOSE_TIME), "timeout")
	_close_popup()
