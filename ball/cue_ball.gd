extends "res://ball/ball.gd"
## Playable Cue Ball
##
## Extends the ball class about features requeired for interaction
## Some information about godots coordinate systems:
## Local: Relative to objects Coordinate system
## Global: Relative to Base canvas layer coordinate system

signal hit_ball()

const AIM_LINE_COLLISION_MASK = 0b00000000_00000000_00000000_00000011
const HIT_STRENGTH = 8
const HIT_MINIMUM_MOUSE_OFFSET = 10

var hit_strength_values = {
	0: 0.5,
	1: 1,
	2: 2,
}
var aim_line
var hit_direction = Vector2(0, 0)
var movement = Vector2(0, 0)
var ball_positioning_click_position
var ball_aiming_release_position

@onready var AimLine = preload("res://ball/aim_line.tscn")
@onready var ready_circle = get_node("CircleEffect")


func _physics_process(delta):
	_ball_in_pocket(delta)
	
	if current_ball_state == BallStates.AIMING:
		_aiming(delta)


func _input(event):
	# To calculate the direction of a hit as long as the player is in hit mode
	if (
			current_ball_state == BallStates.AIMING
			and event is InputEventMouseMotion
	):
		hit_direction = -get_local_mouse_position()
	elif(
			current_ball_state == BallStates.AIMING
			and event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and !event.is_pressed()
	):
		var mouse_offset = (ball_positioning_click_position - event.get_position()).length()
		# Only play ball when mouse has moved for a certail length to avoid
		# ball being hit while placing
		if mouse_offset > HIT_MINIMUM_MOUSE_OFFSET:
			set_ball_state(BallStates.MOVING)
		else:
			set_ball_state(BallStates.PLAYABLE)
			aim_line.queue_free()
	# Save position, where ball was clicked
	elif (
			current_ball_state != BallStates.AIMING
			and event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.is_pressed()
	):
		ball_positioning_click_position = event.get_position()


## Add functionality for playable clue balls
func set_ball_state(state: BallStates):
	super.set_ball_state(state)
	
	if state == BallStates.PLAYABLE:
		# Only for cue ball
		ready_circle.animate()
	elif state == BallStates.AIMING:
		aim_line = AimLine.instantiate()
		add_child(aim_line)
	elif state == BallStates.MOVING:
		var hit_strength_multiplicator = hit_strength_values[
				GameEngine.hit_strength_multiplicator_index]
		var hit_strength = HIT_STRENGTH * hit_strength_multiplicator
		movement = hit_direction * hit_strength
		# Global position of movement vector minus position off cue ball to make
		# it relative
		var movement_global = to_global(movement) - global_position
		apply_impulse(movement_global, Vector2(0, 0))
		# Not sleeping, so ball is not detected as idle when checked next frame
		# by gameplay
		set_sleeping(false)
		aim_line.queue_free()
		audio.get_node("Hit").play()
		emit_signal("hit_ball")


func _aiming(_delta):
	# Returns the state of the space of the current World_2D, to make an
	# intersection query for the prediction
	var space_state = get_world_2d().direct_space_state
	# Convert to local coordinate system without ball rotation
	var hit_direction_without_rotation = to_global(hit_direction) - global_position
	# Vector that is longer than the table diagonally
	var very_long_vector = GameEngine.original_window_size.x + GameEngine.original_window_size.y
	# Defined als the hit direction scaled with the long vector
	var target = global_position + (
			hit_direction_without_rotation.normalized() * very_long_vector)
	
	var intersect_ray_params = PhysicsRayQueryParameters2D.create(
			global_position, target)
	intersect_ray_params.set_collide_with_areas(false)
	intersect_ray_params.set_collision_mask(AIM_LINE_COLLISION_MASK)
	var result = space_state.intersect_ray(intersect_ray_params)
	# Should always have some result
	if result:
		var local_target_position = to_local(result.position)
		aim_line.draw_aim_line(local_target_position)


# Player Input
func _on_ball_input_event(_viewport, event, _shape_idx):
	if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.is_pressed()
			and current_ball_state == BallStates.PLAYABLE
	):
		set_ball_state(BallStates.AIMING)
