extends RigidBody2D

# Member Variables
var radius
var number # Number displayed on the ball
var suit
var pocket # Pocket the ball is inside
var movement = Vector2(0, 0)
var color = Color("white")
var HIT_STRENGTH = 5 # Scalar to balance the intensity of the impuls that is given to a ball
var mouse_drag_scale = 10
var first_collider = true
enum ball_states {
	Normal,
	Aiming,
	InPocket,
}
var current_ball_state = ball_states.Normal
var dummy = 0

var DAMP = 0.7
var SPEED_THRESHOLD_VERY_SLOW = 1
var SPEED_THRESHOLD_SLOW = 100000
var SPEED_THRESHOLD_FAST = 500000
var STRIPED_ANGLE_FROM_CENTER = 50

@onready var game_variables = get_node("/root/GameVariables") # Singleton
@onready var table = get_node("/root/Table")
@onready var GAMEPLAY = get_node("/root/Table/Gameplay")
@onready var player = get_node("/root/Table/Players/Player")
@onready var Audio = get_node("Audio")

const COLORS = {
	"white": Color(0.75, 0.75, 0.75, 1),
	"yellow": Color(0.85, 0.65, 0.28, 1),#
	"violet": Color(0.71, 0.22, 0.82, 1),#
	"black": Color(0.15, 0.15, 0.15, 1),#
	"blue": Color(0.2, 0.35, 0.71, 1),#
	"red": Color(0.78, 0.27, 0.38, 1),#
	"orange": Color(0.66, 0.3, 0.19, 1),#
	"green": Color(0.11, 0.35, 0.17, 1),#
	"dark_red": Color(0.55, 0.2, 0.23, 1),#
}

signal hole_in(ball_number)

# Default gravity in Project Settings set to 0 for RigidBody2D to work
# Linear damp in Project Settings set to 0.3 for realistic speed reduction

func init(
	radius:int = 20,
	number:int = 0,
	color:Color = Color("white"),
	pos:Vector2 = Vector2(0, 0),
	suit = null
	):
	self.radius = radius
	self.number = number
	self.color = color
	self.position = pos
	self.suit = suit
	
	get_node("CollisionShape2D").shape.radius = self.radius
	
	return self
	
func _ready():
	get_node("Label").text = str(number)
	
func _draw():
	draw_circle(Vector2(0,0), self.radius, color)
	draw_circle(Vector2(0,0), self.radius / 2, game_variables.COLORS["white"])
	if suit == game_variables.suits.Stripe:
		draw_circle_arc_poly(Vector2(0, 0), self.radius, -STRIPED_ANGLE_FROM_CENTER, STRIPED_ANGLE_FROM_CENTER, game_variables.COLORS["white"])
		draw_circle_arc_poly(Vector2(0, 0), self.radius, 180-STRIPED_ANGLE_FROM_CENTER, 180+STRIPED_ANGLE_FROM_CENTER, game_variables.COLORS["white"])
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color): # TODO Rename
	var nb_points = 32
	var points_arc = []
	#points_arc.push_back(center)
	var colors = [color]

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
	
func _physics_process(delta):
	ball_in_pocket(delta)
		

func ball_in_pocket(delta):
	if current_ball_state != ball_states.InPocket:
		# Mittelpunkt schneidet mit Area2D, für Prüfung ob Ball in Loch rollt
		var intersect_point_params = PhysicsPointQueryParameters2D.new()
		intersect_point_params.position = get_global_position()
		intersect_point_params.collide_with_areas = true
		intersect_point_params.collide_with_bodies = false
		
		var hole_in = get_world_2d().direct_space_state.intersect_point(intersect_point_params)
		for area in hole_in:
			if(area.collider.name == "Pocket"): # Can collide with itself
 # TODO bug wenn ball nicht aus der pocket rausprallt
				
		#if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Hit or GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.CorrectHit:
				pocket = area.collider
				current_ball_state = ball_states.InPocket
				emit_signal("hole_in", self.number)
				Audio.get_node("PocketSound").play()
				await Audio.get_node("PocketSound").finished
				table.delete_ball(self)
	else:
		# Slow ball
		set_linear_damp(15)
		
		var direction_to_pocket_center = pocket.get_pocket_center() - get_global_position()
		var force_to_pocket_center = direction_to_pocket_center * linear_velocity.length() * 30 * delta
		apply_central_force(force_to_pocket_center)
		#print(force_to_pocket_center)
		#else:
		#	push_warning("Ball in pocket during invalid turn state: " + str(GAMEPLAY.current_turn_state))
	
	
			


func _on_Ball_body_entered(body):
	if body.get_scene_file_path() == self.get_scene_file_path():
		# Hit with another ball
		if first_collider:
			var collision_speed = (linear_velocity - body.linear_velocity).length_squared()
			
			if collision_speed > SPEED_THRESHOLD_VERY_SLOW and collision_speed < SPEED_THRESHOLD_SLOW:
				Audio.get_node("Clack1").play()
			elif collision_speed < SPEED_THRESHOLD_FAST:
				Audio.get_node("Clack2").play()
			else:
				Audio.get_node("Clack3").play()
		body.first_collider = false
		# Hit is correct, when another ball is hit
		if self.number == 0:
			if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Hit:
				if GAMEPLAY.current_game_state != GAMEPLAY.game_states.PocketingEightBall:
					if body.number != 8:
						GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.CorrectHit)
					else:
						GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.Foul)
				else:
					GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.CorrectHit)


func _on_Ball_body_exited(body):
	first_collider = true
