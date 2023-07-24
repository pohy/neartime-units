@tool
class_name PositionTarget
extends Area3D

@export var radius_multiplier: float = 1.
@export var speed: float = 1.

@onready var _collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var _csg_cylinder: CSGCylinder3D = $CSGCylinder3D
@onready var _mouse: Mouse = $Mouse
@onready var _debug_sphere: CSGSphere3D = $DebugSphere

var _cylinder_shape_3d: CylinderShape3D
var _camera: Camera3D
var _snap_target


func _ready():
	_cylinder_shape_3d = _collision_shape_3d.shape as CylinderShape3D
	_camera = get_viewport().get_camera_3d()


func _process(delta):
	sync_csg_to_collision_shape()

	if Engine.is_editor_hint():
		return

	if not _mouse.right:
		move_towards_mouse_cursor()
		try_to_snap_to_cover()


func _on_body_entered(body):
	var dir = (body.global_transform.origin - global_transform.origin).normalized()
	_snap_target = find_snap_target(dir)


func _on_body_exited(body):
	_snap_target = null


func _get_configuration_warnings():
	var warnings = []
	if not _collision_shape_3d.shape:
		warnings.append("CollisionShape3D has no shape.")
	if not _collision_shape_3d.shape is CylinderShape3D:
		warnings.append("CollisionShape3D shape is not a CylinderShape3D.")
	return warnings


func sync_csg_to_collision_shape():
	if not _collision_shape_3d or not _collision_shape_3d.shape:
		return

	_csg_cylinder.radius = _cylinder_shape_3d.radius * radius_multiplier
	_csg_cylinder.height = _cylinder_shape_3d.height


func move_towards_mouse_cursor():
	var result = get_target_position()
	if not result or not result.collider:
		return

	var target_position = position.slerp(result.position, get_process_delta_time() * speed)
	target_position.y = position.y
	position = target_position


func get_target_position() -> Dictionary:
	var origin = _camera.project_ray_origin(_mouse.pos)
	var ray_target = origin + _camera.project_ray_normal(_mouse.pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, ray_target, 0b01, [self])

	var space_state = get_world_3d().direct_space_state
	return space_state.intersect_ray(query)


func try_to_snap_to_cover():
	if _snap_target == null:
		return

	var result = _snap_target as Dictionary
	_debug_sphere.position = result.position + result.normal * _cylinder_shape_3d.radius
	_debug_sphere.look_at(result.position + result.normal, Vector3.UP)


func find_snap_target(dir: Vector3) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(
		position, position + dir * 1000, collision_mask, [self]
	)
	var space_state = get_world_3d().direct_space_state
	return space_state.intersect_ray(query)
