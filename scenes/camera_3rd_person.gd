@tool
class_name Camera3rdPerson
extends Node3D

var _rotation_target: Basis = Basis.IDENTITY
var _target_y_rot: float = 0.0
var _offset: Vector3 = Vector3.ZERO

@onready var _look_target: Node3D = $LookTarget
@onready var _look_direction: Node3D = $LookTarget/Direction
@onready var _camera: Camera3D = $Camera3D
@onready var _mouse: Mouse = $Mouse

@export var offset: Vector3:
	get:
		return _offset
	set(value):
		_offset = value
		if _camera:
			_camera.position = _offset
@export var target: Node3D
@export var sensitivity: Vector2 = Vector2(0.1, 0.1)
@export var speed: float = 1.0
@export var max_camera_rotation: Vector2 = Vector2(-30, 60)
@export var fov: float:
	get:
		return _camera.fov if _camera else 0.
	set(value):
		if _camera:
			_camera.fov = value

var look_target: Node3D:
	get:
		return _look_target
var look_direction: Node3D:
	get:
		return _look_direction


func _ready():
	_rotation_target = target.transform.basis
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta):
	if target:
		position = target.global_transform.origin

	if Engine.is_editor_hint():
		return

	rotate_towards_rotation_target(delta)


func _get_configuration_warnings():
	var warnings = []
	if not target:
		warnings.append("No target set, camera will not move.")
	return warnings


func rotate_towards_rotation_target(delta: float):
	Input.mouse_mode = (Input.MOUSE_MODE_CAPTURED if not _mouse.right else Input.MOUSE_MODE_HIDDEN)

	if not target:
		return

	# if _mouse.right:
	_look_target.rotate_object_local(Vector3.UP, -_mouse.delta.x * sensitivity.x)

	# if not _mouse.right and _mouse.from_center.length() <= 1:
	# 	_look_direction.translate(
	# 		(
	# 			Vector3.RIGHT * -_mouse.delta.x * sensitivity.x * 2.
	# 			+ Vector3.UP * -_mouse.delta.y * sensitivity.y * .5
	# 		)
	# 	)

	self.transform.basis = (
		transform.basis.slerp(_look_target.transform.basis, speed * delta).orthonormalized()
	)

	var next_camera_basis = (
		_camera
		. transform
		. basis
		. slerp(
			_camera.transform.looking_at(_look_direction.position, Vector3.UP).basis, speed * delta
		)
		. orthonormalized()
	)
	var camera_rotation = next_camera_basis.get_euler() * 180 / PI
	if camera_rotation.x > max_camera_rotation.x and camera_rotation.x < max_camera_rotation.y:
		_camera.transform.basis = next_camera_basis


func look_towards_look_target():
	if Engine.is_editor_hint():
		return
	if not target:
		return

	_camera.look_at(_look_target.global_transform.origin, Vector3.UP)


func update_rotation_target(amount):
	if not target:
		return
	_target_y_rot += amount
	var target_y_rot = sign(_target_y_rot) * (abs(int(_target_y_rot)) % 360)
	_rotation_target = Basis.from_euler(Vector3.UP * target_y_rot)
