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
var _material: BaseMaterial3D


func _get_configuration_warnings():
	var warnings = []
	if not _collision_shape_3d.shape:
		warnings.append("CollisionShape3D has no shape.")
	if not _collision_shape_3d.shape is CylinderShape3D:
		warnings.append("CollisionShape3D shape is not a CylinderShape3D.")
	return warnings


func _ready():
	_cylinder_shape_3d = _collision_shape_3d.shape as CylinderShape3D
	assert(
		_cylinder_shape_3d is CylinderShape3D,
		"Not a CylinderShape3D at path: " + str(_collision_shape_3d.shape)
	)

	_material = (
		_csg_cylinder.material if _csg_cylinder.material else _csg_cylinder.material_override
	)
	var unique_material = (
		_material.duplicate(true) if _material is BaseMaterial3D else StandardMaterial3D.new()
	)
	_csg_cylinder.material_override = unique_material
	_material = unique_material


func _process(delta):
	sync_csg_to_collision_shape()

	if Engine.is_editor_hint():
		return

	match _state:
		State.Hidden:
			self.visible = false
		State.Preview:
			self.visible = true
			_material.albedo_color.a = 0.5
		State.Active:
			self.visible = true
			_material.albedo_color.a = 1.0


func sync_csg_to_collision_shape():
	if not _collision_shape_3d or not _collision_shape_3d.shape:
		return

	_csg_cylinder.radius = _cylinder_shape_3d.radius * radius_multiplier
	_csg_cylinder.height = _cylinder_shape_3d.height
