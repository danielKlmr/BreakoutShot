extends RigidBody2D

# Member Variables
var radius
var number # Number displayed on the ball
var suit
var movement = Vector2(0, 0)
var color = Color("white")
var hit_mode = 0 # 1 if the player is currently trying to hit a ball ToDo: bool?
var hit_direction = Vector2(0, 0)
var HIT_STRENGTH = 5 # Scalar to balance the intensity of the impuls that is given to a ball
var mouse_drag_scale = 10
var first_collider = true

var SPEED_THRESHOLD_VERY_SLOW = 1
var SPEED_THRESHOLD_SLOW = 100000
var SPEED_THRESHOLD_FAST = 500000
var STRIPED_ANGLE_FROM_CENTER = 50

@onready var game_variables = get_node("/root/GameVariables") # Singleton
@onready var table = get_node("/root/Table")
@onready var GAMEPLAY = get_node("/root/Table/Gameplay")
@onready var player = get_node("/root/Table/Players/Player")
@onready var aim_line = preload("res://Player/AimLine.tscn")
@onready var Audio = get_node("Audio")

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
	if hit_mode == 1:
		var space_state = get_world_2d().direct_space_state # Returns the state of the space of the current World_2D, to make an intersection query for the prediction
		var target = position + hit_direction.normalized() * (game_variables.x_size + game_variables.y_size) # Defined als the hit direction scaled to a length that is bigger than the table
		var intersect_ray_params = PhysicsRayQueryParameters2D.create(position, target)
		var result = space_state.intersect_ray(intersect_ray_params)
		if result:
			player.get_node("AimLine").draw_aim_line(position, result.position, delta)
	
	# Mittelpunkt schneidet mit Area2D, für Prüfung ob Ball in Loch rollt
	var intersect_point_params = PhysicsPointQueryParameters2D.new()
	intersect_point_params.position = position
	
	var hole_in = get_world_2d().direct_space_state.intersect_point(intersect_point_params)
	for area in hole_in:
		if(area.collider.get_parent().get_parent().name == "Holes"):
			print('Hole!')
			ball_in_pocket()
			
# Player Input
func _on_Ball_input_event(viewport, event, shape_idx):
	if number == 0 and GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Play:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				hit_mode = 1
				var new_aim_line = aim_line.instantiate()
				player.add_child(new_aim_line)

func _input(event):
	# To calculate the direction of a hit as long as the player is in hit mode
	if(hit_mode == 1):
		hit_direction = position - event.position

func _unhandled_input(event):
	# When ball is shot
	if(hit_mode == 1 and GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Play):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if !event.pressed:
					movement = hit_direction * 5
					apply_impulse(movement, Vector2(0, 0))
					set_sleeping(false) # So ball is not detected as idle when checked next frame by gameplay
					player.get_node("AimLine").queue_free()
					Audio.get_node("Hit").play()
					hit_mode = 0
					GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.Hit)

func ball_in_pocket():
	if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Hit or GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.CorrectHit:
		emit_signal("hole_in", self.number)
		Audio.get_node("PocketSound").play()
		await Audio.get_node("PocketSound").finished
		table.delete_ball(self)


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
