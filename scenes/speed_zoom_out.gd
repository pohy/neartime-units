@tool
extends Node3D

@export var amount: float = 10.0
@export var speed: float = 1.0

@onready var _camera: Camera3rdPerson = get_parent()
@onready var _speed: Speed = $Speed

var _initial_fov: float = 0.0


func _get_configuration_warnings():
	var warnings = []
	if not _camera:
		warnings.append("Camera3rdPerson not found in parent")
	if not _camera is Camera3rdPerson:
		warnings.append("Parent is not a Camera3rdPerson")
	return warnings


func _ready():
	_initial_fov = _camera.fov
	_speed.frames = 5


func _process(delta):
	if Engine.is_editor_hint():
		return

	if _initial_fov < 0.1:
		_initial_fov = _camera.fov

	var target_fov = _initial_fov + _speed.speed01 * amount
	_camera.fov = lerp(_camera.fov, target_fov, speed * delta)
