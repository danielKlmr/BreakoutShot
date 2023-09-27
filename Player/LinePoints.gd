extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _draw():
	var direction = (get_points()[0] - get_points()[1]).normalized()
	draw_circle(get_points()[0], 7, Color(1,1,1,1))
	draw_circle(get_points()[0] + direction * 50, 7, Color(1,1,1,1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
