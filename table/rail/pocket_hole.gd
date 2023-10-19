extends StaticBody2D
## Hole of the pocket
##
## Visualization and collision logic of the pocket

const RADIUS = 100
const CORNER_ANGLE_FROM = 45
const CORNER_ANGLE_TO = 225
const SIDE_ANGLE_FROM = 90
const SIDE_ANGLE_TO = 270
const COLOR_SHIFT = -0.4
const SATURATION_SHIFT = +0.2
const CORNER_POCKET_FILE_PATH = "res://table/rail/pocket_corner.tscn"

var color = Color.DARK_GRAY

@onready var pocket_center = get_parent().get_node("PocketCenter")
@onready var pocket_collision_shape = get_node("PocketCollisionShape")

func _ready():
	pocket_collision_shape.shape.radius = RADIUS


func _draw():
	if get_parent().get_scene_file_path() == CORNER_POCKET_FILE_PATH:
		# Drawing center at a different location than pocket center
		GameEngine.draw_circle_arc_poly(
				self, 
				Vector2(0, 0),
				RADIUS,
				CORNER_ANGLE_FROM,
				CORNER_ANGLE_TO,
				color)
	else:
		GameEngine.draw_circle_arc_poly(
				self,
				Vector2(0, 0),
				RADIUS,
				SIDE_ANGLE_FROM,
				SIDE_ANGLE_TO,
				color)


## Give input base color a darker tone and override standard color
func set_color(input_color: Color):
	input_color.s += SATURATION_SHIFT
	input_color.r += COLOR_SHIFT
	input_color.g += COLOR_SHIFT
	input_color.b += COLOR_SHIFT
	color = input_color


## Get center of the pocket, where the ball is supposed to fall
func get_pocket_center():
	
	return pocket_center.get_global_position()
