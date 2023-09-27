extends Node2D

var RADIUS = 70

@onready var CircleAnimation = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	pass
	#queue_redraw()

func _draw():
	draw_circle(Vector2(0, 0), self.RADIUS, Color('lightblue'))

func animate():
	CircleAnimation.play("SignalCircleReady")
