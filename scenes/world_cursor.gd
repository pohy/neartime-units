@tool
class_name WorldCursor
extends Node3D

var _camera: Camera3D
var _mouse: Mouse

@onready var _debug_sphere: MeshInstance3D = $DebugSphere

@export var debug: bool:
	get:
		if not _debug_sphere:
			return false
		return _debug_sphere.visible
	set(value):
		if not _debug_sphere:
			return
		_debug_sphere.visible = value
@export var pos: Vector3 = Vector3.ZERO:
	get:
		return pos


func _ready():
	_camera = get_viewport().get_camera_3d()
	_mouse = $Mouse
	_mouse = _mouse if _mouse else get_parent().get_node("Mouse")
	assert(_mouse is Mouse, "Mouse not found at path: " + str(get_path()))
	update_pos()


func _input(event):
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseMotion:
		update_pos()


func update_pos():
	var result = cast_ray()
	if not result or not result.collider:
		return

	pos = result.position
	_debug_sphere.global_position = result.position


func cast_ray() -> Dictionary:
	var origin = _camera.project_ray_origin(_mouse.pos)
	var direction = origin + _camera.project_ray_normal(_mouse.pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, direction, 0b01, [self])

	var space_state = get_world_3d().direct_space_state
	return space_state.intersect_ray(query)
