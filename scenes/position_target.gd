@tool
extends StaticBody3D

@export var radius_multiplier: float = 1.

@onready var _collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var _csg_cylinder: CSGCylinder3D = $CSGCylinder3D
@onready var _mouse: Mouse = $Mouse

var _cylinder_shape_3d: CylinderShape3D
var _camera: Camera3D


func _ready():
	_camera = get_viewport().get_camera_3d()


func _process(delta):
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


func _on_input_event(
	_camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int
):
	print(
		"on_input_event - event: ",
		event,
		" position: ",
		position,
		" normal: ",
		normal,
		" shape_idx: ",
		shape_idx
	)
	pass  # Replace with function body.


func move_towards_mouse_cursor(event):
	var origin = _camera.project_ray_origin(event.position)
	var ray_target = origin + _camera.project_ray_normal(event.position) * 1000
	var ray = (
		PhysicsRayQueryParameters3D
		. create(
			origin,
			ray_target,
		)
	)

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray)
	if not result or not result.collider:
		return

	var target_position = result.position
	target_position.y = position.y
	position = target_position
