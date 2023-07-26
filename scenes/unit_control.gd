extends Node

@onready var _mouse: Mouse = $Mouse

var _units: Array[Unit] = []
var _position_target_scene: PackedScene = preload("res://scenes/position_target.tscn")

var _position_targets: Dictionary = {}


func _ready():
	for unit in get_tree().get_nodes_in_group("unit"):
		if not unit is CharacterBody3D:
			continue

		_units.append(unit)
		_position_targets[str(unit.get_instance_id())] = _position_target_scene.instantiate()
		add_child(_position_targets[str(unit.get_instance_id())])

	print_debug("Units: ", len(_units))


func _input(event):
	if event is InputEventMouseButton:
		update_move_target()


func update_move_target():
	if not _mouse.left or _mouse.right:
		return

	for unit in _units:
		# TODO: Check if target position is movable to
		var position_target = _position_targets[str(unit.get_instance_id())]
		if not position_target:
			printerr("Position target for the unit not found", unit, position_target)
			print_debug("Position targets: ", _position_targets.keys())
			continue
		unit.move_target = position_target.position
