extends KinematicBody2D

# Uses Kinematicbody instead of Rigidbody to be able to follow mouse

onready var game_variables = get_node("/root/GameVariables")
# var a = 2
# var b = "text"

var mouse_drag_scale = 1000
# Called when the node enters the scene tree for the first time

func init(ball):
	add_child(ball)
	position = ball.position
	ball.position = Vector2(0, 0)
	var shape = ball.get_node("CollisionShape2D")
	add_child(shape.duplicate())
	shape.set_disabled(true)
	ball.set_mode(1)
	
	return self
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var linear_velocity
	if mouse_position.x >= game_variables.head_string_position:
		linear_velocity = (mouse_position - position)
	else:
		var projected_position = mouse_position
		projected_position.x = game_variables.head_string_position
		if (projected_position - game_variables.head_spot_position).length() < game_variables.SNAPPING_DISTANCE:
			set_position(game_variables.head_spot_position)
			linear_velocity = Vector2(0, 0)
		else:
			linear_velocity = projected_position - position
	linear_velocity *= mouse_drag_scale
	move_and_slide(linear_velocity * delta)
