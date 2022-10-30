extends Area2D

onready var game_variables = get_node("/root/GameVariables")

onready var radius = game_variables.ballradius * 1.5 / game_variables.BORDER_SCALE

func _draw():
	draw_circle(Vector2(0,0), radius, Color(0.27, 0.2, 0.2, 1))

func _ready():
	get_node("CollisionShape2D").shape.radius = radius
