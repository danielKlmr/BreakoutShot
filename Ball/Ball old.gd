extends KinematicBody2D

# Singleton
onready var game_variables = get_node("/root/GameVariables")

# Member Variables
var movement = Vector2(0, 0)
var speed = 1000
var number
var color = Color(1, 1, 1, 1)
var hit_mode = 0

func _draw():
	draw_circle(Vector2(0,0), game_variables.ballradius, color)
	draw_circle(Vector2(0,0), game_variables.ballradius / 2, game_variables.COLORS["white"])

func _ready():
	get_node("CollisionShape2D").shape.radius = game_variables.ballradius
	get_node("Label").text = str(number)
	
func _physics_process(delta):
	var collision_info = move_and_collide(movement * delta)
	
	if(collision_info):
		position = position - movement * delta # Vermeidung von Doppelkollisionen
		# Speichere Vektor, der senkrecht zur Aufprallfläche nach außen steht
		# Dieser gilt für den anderen Ball umgekehrt
		var normal_vector = collision_info.normal
		
		if collision_info.collider.filename == (filename):
			var other_ball = collision_info.collider
			
			# Erst wird die Energieübertragung berechnet und vom eigenen Vektor bereits abgezogen
			var given_movement = energy_lost(normal_vector)
			var given_movement_by_other_ball = other_ball.energy_lost(-normal_vector)
			
			# Danach bouncen beide Bälle, sie prallen also aneinander ab
			bounce(movement, normal_vector)
			other_ball.bounce(other_ball.movement, -normal_vector)
			
			# Bekommene Movements werden dazuaddiert
			movement = movement + given_movement_by_other_ball
			other_ball.movement = other_ball.movement + given_movement
		else:
			bounce(movement, normal_vector)
	
	if(movement != Vector2(0, 0)):
		_slow_down(delta)
	
	# Mittelpunkt schneidet mit Area2D, für Prüfung ob Ball in Loch rollt
	var hole_in = get_world_2d().direct_space_state.intersect_point(position, 32, [], 2147483647, false, true)
	for area in hole_in:
		if(area.collider.get_parent().name == "Holes"):
			hole_in()

func _on_Ball_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			hit_mode = 1
		if event.button_index == BUTTON_RIGHT and event.pressed:
			movement = Vector2(-speed, 0)
		if event.button_index == BUTTON_MIDDLE and event.pressed:
			movement = movement + Vector2(speed/2, speed/2)

func _unhandled_input(event):
	if(hit_mode == 1):
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if !event.pressed:
					var direction = position - event.position
					movement = direction * 5
					hit_mode = 0

# Abbremsen durch Reibung
func _slow_down(delta):
	movement = movement * (1 - 0.3 * delta)
	if(movement.length() < 10):
		movement = Vector2(0, 0)

# Energieverlust bei Stoß mit anderer Kugel
func energy_lost(normal_vector):
	var angle = movement.angle_to(normal_vector)
	if(angle < 0): # Negativer Winkel, je nachdem ob links- oder rechtsseitiger aufprall, kann nicht verarbeitet werden
		angle = -angle
	var energy_lost = 1 - (angle / (PI / 2))
	if(energy_lost < 0): # Negativer Energieverlust bei Aufprall von hinten wird umgekehrt
		energy_lost = -energy_lost
	if (energy_lost > 1.001):
		print("Energieverlust über 1!!")
	if(energy_lost > 1.9): # If ball stops immediatly, another kollision will be triggered
		energy_lost = 0.9
	
	var given_movement = movement * energy_lost
	movement = movement - given_movement
	
	return given_movement

func bounce(direction, normal_vector):
	if(direction.angle_to(normal_vector) > PI / 2 || direction.angle_to(normal_vector) < -PI / 2): # Stoß von hinten führt nicht zu bounce
		# Berechne Lotpunkt, um den der normalisierte Geschwindigkeitsvektor gespiegelt wird
		# Quelle: https://www.youtube.com/watch?v=jxjZqfa84Xg
		# Minus movement da für die Formel der umgekehrte Vektor gebraucht wird
		var projection_point = normal_vector.dot(-direction) / normal_vector.length() * normal_vector
		# Bewegungsvektor wird durch zweimalige Addition des Projektionsvektors zum Abprallvektor
		movement = direction + 2 * projection_point

func hole_in():
	queue_free()

func test():
	print("Wuhu")
