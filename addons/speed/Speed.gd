extends Node3D
class_name Speed

@export var frames: int = 60

var speed: float = 0.0
var acceleration: float = 0.0
var last_position: Vector3 = Vector3.ZERO

var speed_avg: float = 0.0
var speed_max: float = 0.0
var speed01: float:
	get:
		if speed_max < 0.0001:
			return 0.0
		return speed_avg / speed_max

var speeds: Array[float] = []


func _ready():
	last_position = global_transform.origin


func _process(delta):
	var current_position = global_transform.origin
	speed = (current_position - last_position).length_squared() / delta
	acceleration = speed - (0 if len(speeds) == 0 else speeds[0])
	update_speed_avg(speed)
	last_position = current_position

	# print_debug("Speed: " + str(speed_avg))


func update_speed_avg(new_speed: float):
	speeds.append(new_speed)

	if speeds.size() > frames:
		speeds.pop_front()

	speed_avg = 0.0
	for s in speeds:
		speed_avg += s
	speed_avg /= speeds.size()

	update_speed_max(speed_avg)


func update_speed_max(new_speed: float):
	if new_speed > speed_max:
		speed_max = new_speed
