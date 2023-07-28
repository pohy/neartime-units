@tool
class_name PositionTarget
extends Area3D

enum State {
	Hidden,
	Preview,
	Active,
}

@export var radius_multiplier: float = 1.
@export var speed: float = 1.

@onready var _collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var _csg_cylinder: CSGCylinder3D = $CSGCylinder3D
# @onready var _debug_sphere: CSGSphere3D = $DebugSphere

var _cylinder_shape_3d: CylinderShape3D
var _state: State = State.Hidden:
	set(value):
		_state = value
		# print_debug("state_changed", _state)
var _material: BaseMaterial3D


func _ready():
	_cylinder_shape_3d = _collision_shape_3d.shape as CylinderShape3D
	_material = (
		_csg_cylinder.material if _csg_cylinder.material else _csg_cylinder.material_override
	)
	assert(
		_material is BaseMaterial3D,
		"No material found on CSGCylinder3D. Path: " + str(_csg_cylinder.get_path())
	)


func _process(delta):
	sync_csg_to_collision_shape()

	match _state:
		State.Hidden:
			self.visible = false
		State.Preview:
			self.visible = true
			_material.albedo_color.a = 0.5
		State.Active:
			self.visible = true
			_material.albedo_color.a = 1.0


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
