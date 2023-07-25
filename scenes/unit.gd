class_name Unit
extends CharacterBody3D

@export var camera: Camera3rdPerson
@export var speed: float = 1.0
@export var rotation_speed: float = 1.0
@export var move_target: Vector3 = Vector3.ZERO

# TODO: Change the input implementation
# @onready var _input: Inpt = $Input
@onready var _body: CollisionShape3D = $CollisionShape3D

var _body_look_target: Vector3 = Vector3.ZERO


func _get_configuration_warnings():
	var warnings = []
	if not camera:
		warnings.append("No camera assigned to the character")
	return warnings


func _process(delta):
	if Engine.is_editor_hint() or not move_target:
		return

	# var input_dir = Vector3(_input.dir.x, 0, _input.dir.y)
	var target_dir = move_target - position

	if target_dir.length_squared() < 0.1:
		move_target = position
		return

	var input_dir = target_dir.normalized()
	input_dir.y = 0
	var dir_camera = input_dir.rotated(Vector3.UP, camera.look_target.rotation.y)

	# TODO: Refactor the mesh body look at into its own re-usable component
	var input_look_target = camera.look_target.global_transform.origin + dir_camera * -1
	_body_look_target = _body_look_target.lerp(input_look_target, rotation_speed * delta)
	_body.look_at(_body_look_target, Vector3.UP)