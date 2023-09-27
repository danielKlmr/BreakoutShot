extends "res://Ball/Ball.gd"

var hit_direction = Vector2(0, 0)
var target_d = Vector2(0, 0)

@onready var aim_line = preload("res://Player/AimLine.tscn")
@onready var ReadyCircle = get_node("ReadyCircle")

# Local: Relative to objects Coordinate system
# Global: Relative to Base canvas layer coordinate system

# Transform from local to global with m.basis_xform(pos)
# reverse with .mbasis_xform_inv(pos)
# for every transformed node in the hierarchy!


func _physics_process(delta):
	ball_in_pocket(delta)
	
	if current_ball_state == ball_states.Aiming:
		aiming(delta)
		
			
func aiming(delta):
	var space_state = get_world_2d().direct_space_state # Returns the state of the space of the current World_2D, to make an intersection query for the prediction
	var hit_global = to_global(hit_direction) - global_position#self.transform.basis_xform(hit_direction)
	var target = global_position + (hit_global.normalized() * (game_variables.window_size.x + game_variables.window_size.y)) # Defined als the hit direction scaled to a length that is bigger than the table
	target_d = target
	
	var intersect_ray_params = PhysicsRayQueryParameters2D.create(global_position, target)
	var result = space_state.intersect_ray(intersect_ray_params)
	if result:
		var local_target_position = to_local(result.position)#self.transform.basis_xform_inv(result.position - global_position)
		self.get_node("AimLine").draw_aim_line(position, local_target_position, delta)
			
# Player Input
func _on_Ball_input_event(viewport, event, shape_idx):
	if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Play:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				current_ball_state = ball_states.Aiming
				var new_aim_line = aim_line.instantiate()
				self.add_child(new_aim_line)

func _input(event):
	# To calculate the direction of a hit as long as the player is in hit mode
	if(current_ball_state == ball_states.Aiming):
		hit_direction = -get_local_mouse_position()

func _unhandled_input(event):
	# When ball is shot
	if(current_ball_state == ball_states.Aiming and GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Play):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if !event.pressed:
					shoot_ball()

func shoot_ball():
	movement = hit_direction * 5
	# Global position of movement vector minus position off cue ball to make it relative
	var movement_global = to_global(movement) - global_position
	apply_impulse(movement_global, Vector2(0, 0))
	set_sleeping(false) # So ball is not detected as idle when checked next frame by gameplay
	self.get_node("AimLine").queue_free()
	Audio.get_node("Hit").play()
	current_ball_state = ball_states.Normal
	GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.Hit)
