extends RigidBody2D

# Member Variables
var number # Number displayed on the ball
var suit
var movement = Vector2(0, 0)
var color = Color(ColorN("white"))
var hit_mode = 0 # 1 if the player is currently trying to hit a ball ToDo: bool?
var hit_direction = Vector2(0, 0)
var HIT_STRENGTH = 5 # Scalar to balance the intensity of the impuls that is given to a ball
var mouse_drag_scale = 10

onready var game_variables = get_node("/root/GameVariables") # Singleton
onready var table = get_node("/root/Table")
onready var GAMEPLAY = get_node("/root/Table/Gameplay")
onready var player = get_node("/root/Table/Players/Player")
onready var aim_line = preload("res://Player/AimLine.tscn")

signal hole_in(ball_number)

# Default gravity in Project Settings set to 0 for RigidBody2D to work
# Linear damp in Project Settings set to 0.3 for realistic speed reduction

func init(
	number:int = 0,
	color:Color = Color(ColorN("white")),
	pos:Vector2 = Vector2(0, 0),
	suit = null
	):
	self.number = number
	self.color = color
	self.position = pos
	self.suit = suit
	
	return self
	
func _ready():
	get_node("CollisionShape2D").shape.radius = game_variables.ballradius
	get_node("Label").text = str(number)
	
func _draw():
	draw_circle(Vector2(0,0), game_variables.ballradius, color)
	draw_circle(Vector2(0,0), game_variables.ballradius / 2, game_variables.COLORS["white"])
	
func _physics_process(delta):
	if hit_mode == 1:
		var space_state = get_world_2d().direct_space_state # Returns the state of the space of the current World_2D, to make an intersection query for the prediction
		var target = position + hit_direction.normalized() * (game_variables.x_size + game_variables.y_size) # Defined als the hit direction scaled to a length that is bigger than the table
		var result = space_state.intersect_ray(position, target)
		if result:
			player.get_node("AimLine").draw_aim_line(position, result.position, delta)
	
	# Mittelpunkt schneidet mit Area2D, für Prüfung ob Ball in Loch rollt
	var hole_in = get_world_2d().direct_space_state.intersect_point(position, 32, [], 2147483647, false, true)
	for area in hole_in:
		if(area.collider.get_parent().get_parent().name == "Holes"):
			hole_in()
			
# Player Input
func _on_Ball_input_event(viewport, event, shape_idx):
	if number == 0 and GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Play:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				hit_mode = 1
				var new_aim_line = aim_line.instance()
				player.add_child(new_aim_line)

func _input(event):
	# To calculate the direction of a hit as long as the player is in hit mode
	if(hit_mode == 1):
		hit_direction = position - event.position

func _unhandled_input(event):
	# When ball is shot
	if(hit_mode == 1 and GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Play):
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if !event.pressed:
					movement = hit_direction * 5
					apply_impulse(Vector2(0, 0), movement)
					set_sleeping(false) # So ball is not detected as idle when checked next frame by gameplay
					player.get_node("AimLine").queue_free()
					hit_mode = 0
					GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.Hit)

func hole_in():
	if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Hit or GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.CorrectHit:
		emit_signal("hole_in", self.number)
		table.delete_ball(self)


func _on_Ball_body_entered(body):
	# Hit is correct, when another ball is hit
	if self.number == 0:
		if body.get_filename() == self.get_filename():
			if GAMEPLAY.current_turn_state == GAMEPLAY.turn_states.Hit:
				if GAMEPLAY.current_game_state != GAMEPLAY.game_states.PocketingEightBall:
					if body.number != 8:
						GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.CorrectHit)
					else:
						GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.Foul)
				else:
					GAMEPLAY.set_turn_state(GAMEPLAY.turn_states.CorrectHit)
