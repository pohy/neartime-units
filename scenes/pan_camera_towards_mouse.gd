@tool
class_name PanCameraTowardsMouse
extends Node

@export var amount: float = 1.0
@export var target_path: NodePath

@onready var mouse: Mouse = $Mouse

var _camera: Node3D
var _target_node: Node3D


func _get_configuration_warnings():
	var warnings = []
	if not target_path:
		warnings.append("Target is empty")
	if not _target_node is Node3D:
		warnings.append("Target is not a Node3D")
	return warnings


func _ready():
	_target_node = get_viewport().get_camera_3d()
	assert(_target_node != null, "Node at path " + str(target_path) + " not found")
	assert(_target_node is Node3D, "Node at path " + str(target_path) + " is not a Node3D")

	# _target_node = get_node(target_path)
	_camera = get_parent()
	# assert(_camera != null, "Camera3D not found in viewport")


func _process(delta):
	if Engine.is_editor_hint():
		return

	if not _target_node:
		return

	if mouse.from_center.length() > 1:
		return

	var next_rotation = Vector3(mouse.delta.y, -mouse.from_center.x, 0)
	next_rotation.y = 0
	_target_node.rotation += next_rotation * amount * delta
