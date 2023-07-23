@tool
class_name Camera3rdPerson
extends Node3D

@export var offset: Vector3 = Vector3.ZERO
@export var target: Node3D
@export var sensitivity: float = 0.1
@export var speed: float = 1.0

@onready var _look_target: Node3D = $LookTarget
@onready var _current_look_target: Node3D = $CurrentLookTarget  # TODO: Not needed???
@onready var _camera: Camera3D = $Camera3D

var _rotation_target: Basis = Basis.IDENTITY
var _target_y_rot: float = 0.0


func _ready():
	_rotation_target = target.transform.basis


func _process(delta):
	position = target.global_transform.origin

	if Engine.is_editor_hint():
		return

	look_towards_look_target()
	rotate_towards_rotation_target(delta)


func _input(event):
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)


func _get_configuration_warnings():
	var warnings = []
	if not target:
		warnings.append("No target set, camera will not move.")
	return warnings


func rotate_towards_rotation_target(delta: float):
	if not target:
		return
	# transform = transform.interpolate_with(_rotation_target, delta * speed)
	var pre_slerp_basis = Basis(transform.basis)
	transform.basis = transform.basis.slerp(_rotation_target, speed * delta).orthonormalized()
	_target_y_rot -= transform.basis.get_euler().y - pre_slerp_basis.get_euler().y
	print_debug("🌡️ transform.basis.get_euler().y", transform.basis.get_euler().y)


func look_towards_look_target():
	if Engine.is_editor_hint():
		return
	if not target:
		return

	_camera.look_at(_look_target.global_transform.origin, Vector3.UP)


func handle_mouse_motion(event):
	if not target:
		return
	# _rotation_target = _rotation_target.rotated(Vector3.UP, -event.relative.x * sensitivity)
	# _target_y_rot -= event.relative.x * sensitivity
	# var pre_rotation_target = _rotation_target
	# print_debug("🩻 PRE rotation_target", pre_rotation_target)
	# var target_y_rot = sign(_target_y_rot) * (abs(int(_target_y_rot)) % 360)
	# print_debug("😳 _target_y_rot", _target_y_rot, "_target_y_rot % 360", target_y_rot)
	# _rotation_target = Basis(Vector3.UP, target_y_rot)
	_rotation_target = _rotation_target.rotated(Vector3.UP, -event.relative.x * sensitivity)
	# print_debug("🫀 rotation_target", _rotation_target)
	# print_debug("🦕 delta", _rotation_target.get_euler() - pre_rotation_target.get_euler())
