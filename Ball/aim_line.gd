extends Path2D
## Dotted aim line between ball and target
##
## Is activated when the cue ball is in aiming mode

const CIRCLE_COLOR = Color.WHITE
const CIRCLE_SIZE = 7
const DISTANCE = 30
const SPEED = 100

var aim_line_length = 0
var current_rest = 0
var line = get_curve()

var TrajectoryPoint = preload("res://Player/TrajectoryPoint.tscn")


func _process(delta):
	_move_and_remove_circles(delta)
	_create_circles(delta)
	
	
func _draw():
	for circle in get_children():
		draw_circle(circle.position, CIRCLE_SIZE, CIRCLE_COLOR)


## Draw aim line from cue ball to target
func draw_aim_line(target : Vector2):
	line.set_point_position(0, Vector2(0, 0))
	line.set_point_position(1, target)
	
	# Check if there is room for new circles and create them
	if get_child_count() > 0:
		var furthest_point_progress = get_child(0).progress
		var remaining_length_to_target = line.get_baked_length() - furthest_point_progress
		
		if remaining_length_to_target > DISTANCE:
			var number_new_points = floor(remaining_length_to_target / DISTANCE)
			_init_circles(
					furthest_point_progress + DISTANCE,
					number_new_points,
					true)
	
	queue_redraw()


## Create a given number of circles from a starting position
func _init_circles(start_offset, number_circles, at_end=false):
	for circle_number in number_circles:
		var circle = TrajectoryPoint.instantiate()
		add_child(circle)
		# If circles are to be created at the end, they are moved to the first
		# position in the child list
		if at_end:
			move_child(circle, 0)
		circle.progress = start_offset + (circle_number * DISTANCE)


## Let circles move each frame and remove them at the end of the aim line
func _move_and_remove_circles(delta):
	for circle in get_children():
		if circle.progress_ratio < 1:
			circle.progress += SPEED * delta
		else:
			circle.queue_free()


## Create a new circle, when the distance between cue ball and the first cicle
## is larger than the distance
func _create_circles(delta):
	if current_rest < DISTANCE:
		current_rest += SPEED * delta
	else:
		var circle = TrajectoryPoint.instantiate()
		add_child(circle)
		current_rest -= DISTANCE
		circle.progress = current_rest
