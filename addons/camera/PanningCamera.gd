extends Node3D
class_name PanningCamera

@export var acceleration: float = 1
@export var max_speed: float = 10
@export var zoom_out: float = 2

@onready var panning_area: PanningArea = $PanningArea
@onready var camera: Camera3D = $Camera3D

var target: Vector3 = Vector3.ZERO
var speed: float = 0
var pan_side: Vector2 = Vector2.ZERO
var move_target: Vector3:
	get: return Vector3(pan_side.x, 0, pan_side.y)
var initial_fov: float = 0
var last_target: Vector3 = Vector3.ZERO

func _ready():
	panning_area.active_side_changed.connect(_on_active_side_changed)
	initial_fov = camera.fov

func _process(delta):
	# speed = min(max_speed, speed + min(1, pan_side.length()) * acceleration) * delta
	speed += min(1, pan_side.length()) * acceleration
	speed -= min(1, speed) * acceleration * 0.1
	speed = min(max_speed, speed)
	speed = max(0, speed)
	# print_debug("speed: " + str(speed))
	# speed *= delta

	target = position + (move_target if move_target.length_squared() > 0 else last_target)
	position = position.move_toward(target, speed * delta)

	if move_target.length_squared() > 0:
		last_target = move_target

	# camera.fov = initial_fov + speed * 0.1
	camera.fov = initial_fov + speed * zoom_out

func _on_active_side_changed(active_side: Vector2) -> void:
	# print_debug("active side changed to: " + str(active_side))
	pan_side = active_side
