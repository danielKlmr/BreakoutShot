extends Path2D

var trajectoryPoint = preload("res://Player/TrajectoryPoint.tscn")

var speed = 100
var distance = 30
var aim_line_length = 0
var current_rest = 0
var circle_size = 7


func _process(delta):
	#rotation = -get_parent().get_rotation() # Ignore Parents rotation
	for circle in self.get_children():
		if circle.progress_ratio >= 1:
			circle.queue_free()
		else:
			circle.progress += speed * delta
	
	if current_rest >= distance:
		var circle = trajectoryPoint.instantiate()
		self.add_child(circle)
		circle.progress = current_rest - distance
		current_rest = 0
	else:
		current_rest += speed * delta	
	
func _draw():
	#draw_line(get_curve().get_point_position(0), get_curve().get_point_position(1), Color.RED, 5, true)
	for circle in get_children():
		draw_circle(circle.position, circle_size, Color.WHITE)
		
func draw_aim_line(ball : Vector2, target : Vector2, delta):
	get_curve().set_point_position(0, Vector2(0, 0))
	get_curve().set_point_position(1, target)
	
	if get_child_count() > 0:
		var remaining_length_to_target = get_curve().get_baked_length() - get_child(0).progress
		if remaining_length_to_target > distance:
			var number_new_points = floor(remaining_length_to_target / distance)
			_init_circles(get_child(0).progress + distance, remaining_length_to_target, true)
	
	queue_redraw()

func _init_circles(start_offset, number_circles, at_end=false):
	for circle_number in number_circles:
		var circle = trajectoryPoint.instantiate()
		self.add_child(circle)
		if at_end:
			self.move_child(circle, 0)
		circle.progress = start_offset + circle_number * distance
