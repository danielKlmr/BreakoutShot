extends CharacterBody2D

# Uses Kinematicbody instead of Rigidbody to be able to follow mouse

@onready var game_variables = get_node("/root/GameVariables")
@onready var Table = get_node("/root/Table")
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
	ball.set_freeze_enabled(true)
	
	return self
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mouse_position = get_parent().get_local_mouse_position() # On PlayingField

	var linear_velocity
	if mouse_position.x >= game_variables.head_string_position:
		# Move ball to mouse if mouse is in head field
		linear_velocity = (get_global_mouse_position() - global_position)
	else:
		var projected_position = mouse_position
		projected_position.x = game_variables.head_string_position
		if (projected_position - Vector2(Table.head_spot_position)).length() < game_variables.SNAPPING_DISTANCE:
			# Snap ball to head spot if it is close to it
			set_position(Table.head_spot_position)
			linear_velocity = Vector2(0, 0)
		else:
			linear_velocity = to_global(projected_position) - to_global(position)
	linear_velocity *= mouse_drag_scale
	set_velocity(linear_velocity * delta)
	move_and_slide()
