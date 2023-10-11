extends RigidBody2D
## Ball
##
## States and actions of the balls. Cue ball is derived from this class.
## Default gravity in Project Settings set to 0 for RigidBody2D to work.
## Linear damp in Project Settings set to 0.3 for realistic speed reduction.

signal strike_object_ball(other_ball_number)
signal ball_in_pocket(ball)

enum BallStates {
	NORMAL,
	AIMING,
	IN_POCKET,
}
enum Suits {
	STRIPE,
	SOLID,
}

const SPEED_THRESHOLD_VERY_SLOW = 1
const SPEED_THRESHOLD_SLOW = 100000
const SPEED_THRESHOLD_FAST = 500000
const STRIPED_ANGLE_FROM_CENTER = 50

# Number displayed on the ball
var number
var suit
# Pocket the ball is inside
var pocket
var _radius
var _color = Color("white")
var first_collider = true
var current_ball_state = BallStates.NORMAL

@onready var collision_shape = get_node("CollisionShape2D")
@onready var label = get_node("Label")
@onready var audio = get_node("Audio")


func init(
	init_radius:int = 20,
	init_number:int = 0,
	init_color:Color = Color("white"),
	init_position:Vector2 = Vector2(0, 0),
	init_suit = null
	):
	self._radius = init_radius
	self.number = init_number
	self._color = init_color
	self.position = init_position
	self.suit = init_suit
	
	return self


func _ready():
	label.text = str(number)
	collision_shape.shape.radius = _radius


func _physics_process(delta):
	_ball_in_pocket(delta)


func _draw():
	draw_circle(Vector2(0,0), _radius, _color)
	draw_circle(Vector2(0,0), _radius / 2, GameVariables.COLORS["white"])
	if suit == Suits.STRIPE:
		_draw_white_stripes(
				Vector2(0, 0),
				_radius,
				-STRIPED_ANGLE_FROM_CENTER,
				STRIPED_ANGLE_FROM_CENTER,
				GameVariables.COLORS["white"])
		_draw_white_stripes(
				Vector2(0, 0),
				_radius,
				180 - STRIPED_ANGLE_FROM_CENTER,
				180 + STRIPED_ANGLE_FROM_CENTER,
				GameVariables.COLORS["white"])


## Draw arcs on the side of the ball if it is striped
func _draw_white_stripes(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = []

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(
				angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(
				center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	draw_colored_polygon(points_arc, color)



func set_ball_state(state: BallStates):
	current_ball_state = state
	
	if state == BallStates.IN_POCKET:
		emit_signal("ball_in_pocket", self)


func _ball_in_pocket(delta):
	if current_ball_state != BallStates.IN_POCKET:
		# Mittelpunkt schneidet mit Area2D, für Prüfung ob Ball in Loch rollt
		var intersect_point_params = PhysicsPointQueryParameters2D.new()
		intersect_point_params.position = get_global_position()
		intersect_point_params.collide_with_areas = true
		intersect_point_params.collide_with_bodies = false
		
		var intersecting_areas = get_world_2d().direct_space_state.intersect_point(intersect_point_params)
		for area in intersecting_areas:
			if(area.collider.name == "Pocket"): # Can collide with itself
 # TODO bug wenn ball nicht aus der pocket rausprallt
				
				pocket = area.collider
				set_ball_state(BallStates.IN_POCKET)

	else:
		# Slow ball
		set_linear_damp(15)
		
		var direction_to_pocket_center = pocket.get_pocket_center() - get_global_position()
		var force_to_pocket_center = direction_to_pocket_center * linear_velocity.length() * 30 * delta
		apply_central_force(force_to_pocket_center)




func _on_Ball_body_entered(body):
	if body.get_scene_file_path() == self.get_scene_file_path():
		# Hit with another ball
		if first_collider:
			var collision_speed = (linear_velocity - body.linear_velocity).length_squared()
			
			if collision_speed > SPEED_THRESHOLD_VERY_SLOW and collision_speed < SPEED_THRESHOLD_SLOW:
				audio.get_node("Clack1").play()
			elif collision_speed < SPEED_THRESHOLD_FAST:
				audio.get_node("Clack2").play()
			else:
				audio.get_node("Clack3").play()
		body.first_collider = false
		# Hit is correct, when another ball is hit
		if self.number == 0:
			emit_signal("strike_object_ball", body.number)


func _on_Ball_body_exited(_body):
	first_collider = true
