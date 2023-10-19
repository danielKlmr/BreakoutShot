extends Node2D

const CIRCLE_COLOR = Color.LIGHT_BLUE
const CIRCLE_RADIUS = 70

@onready var circle_animation = get_node("AnimationPlayer")


func _draw():
	draw_circle(Vector2(0, 0), CIRCLE_RADIUS, CIRCLE_COLOR)


## Plays animation to show that ball is ready to be played
func animate():
	circle_animation.play("SignalCircleReady")
