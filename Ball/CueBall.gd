extends "res://ball/ball.gd"

var hit_strength_values = {
	0: 0.5,
	1: 1,
	2: 2,
}

var hit_direction = Vector2(0, 0)
var target_d = Vector2(0, 0)
var movement = Vector2(0, 0)

@onready var aim_line = preload("res://Player/AimLine.tscn")
@onready var ReadyCircle = get_node("ReadyCircle")
@onready var GAMEPLAY = get_node("/root/Table/Gameplay")

# Local: Relative to objects Coordinate system
# Global: Relative to Base canvas layer coordinate system

# Transform from local to global with m.basis_xform(pos)
# reverse with .mbasis_xform_inv(pos)
# for every transformed node in the hierarchy!


func _physics_process(delta):
	_ball_in_pocket(delta)
	
	if current_ball_state == BallStates.AIMING:
		aiming(delta)
		
			
func aiming(delta):
	var space_state = get_world_2d().direct_space_state # Returns the state of the space of the current World_2D, to make an intersection query for the prediction
	var hit_global = to_global(hit_direction) - global_position#self.transform.basis_xform(hit_direction)
	var target = global_position + (hit_global.normalized() * (GameEngine.original_window_size.x + GameEngine.original_window_size.y)) # Defined als the hit direction scaled to a length that is bigger than the table
	target_d = target
	
	var intersect_ray_params = PhysicsRayQueryParameters2D.create(global_position, target)
	var result = space_state.intersect_ray(intersect_ray_params)
	if result:
		var local_target_position = to_local(result.position)#self.transform.basis_xform_inv(result.position - global_position)
		self.get_node("AimLine").draw_aim_line(local_target_position)
			
# Player Input
func _on_Ball_input_event(viewport, event, shape_idx):
	if GAMEPLAY.current_turn_state == GAMEPLAY.TurnStates.PLAY:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				current_ball_state = BallStates.AIMING
				var new_aim_line = aim_line.instantiate()
				self.add_child(new_aim_line)

func _input(event):
	# To calculate the direction of a hit as long as the player is in hit mode
	if(current_ball_state == BallStates.AIMING):
		hit_direction = -get_local_mouse_position()

func _unhandled_input(event):
	# When ball is shot
	if(
		current_ball_state == BallStates.AIMING
		and GAMEPLAY.current_turn_state == GAMEPLAY.TurnStates.PLAY
	):
		# TODO: dont hit when placing
		if event is InputEventMouseButton:
			if (
					event.button_index == MOUSE_BUTTON_LEFT
					and !event.is_pressed()
			):
					print("shoot!")
					shoot_ball()

func shoot_ball():
	var hit_strength = GameVariables.HIT_STRENGTH * hit_strength_values[GameVariables.hit_strength_multiplicator_index]
	movement = hit_direction * hit_strength
	# Global position of movement vector minus position off cue ball to make it relative
	var movement_global = to_global(movement) - global_position
	apply_impulse(movement_global, Vector2(0, 0))
	print(movement_global)
	set_sleeping(false) # So ball is not detected as idle when checked next frame by gameplay
	self.get_node("AimLine").queue_free()
	audio.get_node("Hit").play()
	current_ball_state = BallStates.NORMAL
	GAMEPLAY.set_turn_state(GAMEPLAY.TurnStates.HIT)
