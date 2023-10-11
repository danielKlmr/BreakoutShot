extends StaticBody2D

# How much should be drawn outside of the intended window
const OUTSIDE_DRAWING = 5000

var drawing_length = 0
var drawing_color = Color("white")

@onready var collision_shape = get_node("CollisionShape2D")


func _draw():
	draw_rect(
			Rect2(
					Vector2(-OUTSIDE_DRAWING, -drawing_length / 2),
					Vector2(OUTSIDE_DRAWING, drawing_length)),
			drawing_color)


## Set size of the border
func set_size(length, rail_thickness):
	drawing_length = length
	collision_shape.scale.x = rail_thickness
	collision_shape.position.x = -rail_thickness / 2
	collision_shape.scale.y = length
	queue_redraw()


## Set color of the border
func set_color(color):
	drawing_color = color
	queue_redraw()
