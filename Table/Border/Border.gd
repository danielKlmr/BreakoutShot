extends StaticBody2D

@onready var game_variables = get_node("/root/GameVariables")

var drawing_length = 0
var drawing_color = Color("white")

func _draw():
	draw_rect(
			Rect2(
				Vector2(-game_variables.OUTSIDE_DRAWING, -drawing_length / 2),
				Vector2(game_variables.OUTSIDE_DRAWING, drawing_length)),
			drawing_color)
	
func set_size(length):
	drawing_length = length
	get_node("CollisionShape2D").scale.x = game_variables.BORDER_THICKNESS
	get_node("CollisionShape2D").position.x = -game_variables.BORDER_THICKNESS / 2
	get_node("CollisionShape2D").scale.y = length
#	get_node("CollisionShape2D").shape = RectangleShape2D.new().set_extents(Vector2(game_variables.BORDER_THICKNESS, length))
	queue_redraw()
	
func set_color(color):
	drawing_color = color
	
#	if(orientation == 0):
#		get_child(0).set_region_rect(Rect2(0, 0, 100, game_variables.x_size * 5))
#		get_child(1).set_region_rect(Rect2(0, 0, 60, game_variables.x_size * 2))
#		get_child(2).shape.extents.y = game_variables.x_size
#
#		get_node("Corner").scale.x = sqrt((game_variables.x_size * game_variables.x_size) / 2)
#		get_node("Corner").scale.y = get_node("Corner").scale.x
#	if(orientation == 1):
#		get_child(0).set_region_rect(Rect2(0, 0, 100, game_variables.y_size * 5))
#		get_child(1).set_region_rect(Rect2(0, 0, 60, game_variables.y_size * 2))
#		get_child(2).shape.extents.y = game_variables.y_size
#
#		get_node("Corner").visible = false
#		get_node("Wood").light_mask = 1
#		get_node("Felt").light_mask = 1
