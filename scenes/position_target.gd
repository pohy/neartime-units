@tool
extends Area3D

@export var radius_multiplier: float = 1.

@onready var _collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var _csg_cylinder: CSGCylinder3D = $CSGCylinder3D
@onready var _mouse: Mouse = $Mouse

var _cylinder_shape_3d: CylinderShape3D
var _camera: Camera3D


func _ready():
	_cylinder_shape_3d = _collision_shape_3d.shape as CylinderShape3D
	_camera = get_viewport().get_camera_3d()


func _process(delta):
	if not _collision_shape_3d or not _collision_shape_3d.shape:
		return

	_cylinder_shape_3d = _collision_shape_3d.shape as CylinderShape3D
	_csg_cylinder.radius = _cylinder_shape_3d.radius * radius_multiplier
	_csg_cylinder.height = _cylinder_shape_3d.height


func _input(event):
	if event is InputEventMouseMotion and not _mouse.right:
		move_towards_mouse_cursor(event)


func _get_configuration_warnings():
	var warnings = []
	if not _collision_shape_3d.shape:
		warnings.append("CollisionShape3D has no shape.")
	if not _collision_shape_3d.shape is CylinderShape3D:
		warnings.append("CollisionShape3D shape is not a CylinderShape3D.")
	return warnings


func move_towards_mouse_cursor(event: InputEventMouseMotion):
	var result = get_target_position()
	if not result or not result.collider:
		return

	var target_position = result.position
	target_position.y = position.y
	position = target_position


func get_target_position() -> Dictionary:
	var origin = _camera.project_ray_origin(_mouse.pos)
	var ray_target = origin + _camera.project_ray_normal(_mouse.pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, ray_target, 0b01, [self])

	var space_state = get_world_3d().direct_space_state
	return space_state.intersect_ray(query)


func _on_body_entered(body: StaticBody3D):
	if not body.is_in_group("cover"):
		return
	var query = PhysicsShapeQueryParameters3D.new()
	query.transform = transform
	query.shape = _cylinder_shape_3d
	query.shape_rid = _cylinder_shape_3d.get_rid()
	query.exclude = [self]
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_shape(query)
	print_debug("Will snap to cover", result)
	if not result or not result.collider:
		return
	pass  # Replace with function body.


func _on_body_exited(body):
	pass  # Replace with function body.
