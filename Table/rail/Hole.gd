extends Area2D

@onready var game_variables = get_node("/root/GameVariables")

#onready var radius = game_variables.ballradius * 1.5 / game_variables.BORDER_SCALE
var radius = 100

func _draw():
	#draw_circle(Vector2(0,0), radius, Color(0.27, 0.2, 0.2, 1))
	if get_parent().get_scene_file_path() == "res://table/rail/pocket_corner.tscn":
		draw_circle_arc_poly(Vector2(0, 0), radius, 45, 225, Color(0.27, 0.2, 0.2, 1)) # Drawed center at a different location than pocket center
	else:
		draw_circle_arc_poly(Vector2(0, 0), radius, 90, 270, Color(0.27, 0.2, 0.2, 1))
	#draw_circle((Vector2(0, 50)), 5, Color("green"))
	#draw_circle(Vector2(0, 0), 5, Color("white")) # TODO fixthis
	#print(get_position())

func _process(delta):
	queue_redraw()

func _ready():
	get_node("CollisionShape2D").shape.radius = radius
	get_node("PositionerCollider/CollisionShape2D").shape.radius = radius

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = []
	points_arc.push_back(center)
	var colors = [color]

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func get_pocket_center():
	return get_parent().get_node("PocketCenter").get_global_position()
