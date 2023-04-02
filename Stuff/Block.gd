extends CharacterBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mouse_drag_scale = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = get_node("Ball").get_node("CollisionShape2D")
	add_child(shape.duplicate())
	shape.set_disabled(true)
	get_node("Ball").set_mode(1)

func _physics_process(delta):
	var linear_velocity = get_global_mouse_position() - position
	linear_velocity *= mouse_drag_scale
	linear_velocity *= delta
	set_velocity(linear_velocity)
	move_and_slide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
