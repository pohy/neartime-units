@tool
class_name Camera3rdPerson
extends Node3D

@export var offset: Vector3 = Vector3.ZERO
@export var target: Node3D
@export var sensitivity: float = 0.1
@export var speed: float = 1.0

@onready var _look_target: Node3D = $LookTarget
@onready var _camera: Camera3D = $Camera3D
@onready var _mouse: Mouse = $Mouse

var _rotation_target: Basis = Basis.IDENTITY
var _target_y_rot: float = 0.0


func _ready():
	_rotation_target = target.transform.basis


func _process(delta):
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
	if not target:
		return
	if not _mouse.right:
		_target_y_rot = 0.
		return

	_target_y_rot += -_mouse.delta.x * sensitivity

	_rotation_target = Basis.from_euler(Vector3.UP * _target_y_rot, EULER_ORDER_XYZ)

	var begin_rotation_y = transform.basis.get_euler(EULER_ORDER_XYZ).y
	transform.basis = transform.basis.slerp(_rotation_target, speed * delta).orthonormalized()

	_target_y_rot -= begin_rotation_y - transform.basis.get_euler(EULER_ORDER_XYZ).y


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
