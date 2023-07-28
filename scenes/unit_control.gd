extends Node

@onready var _mouse: Mouse = $Mouse

var _units: Array[Unit] = []
var _position_target_scene: PackedScene = preload("res://scenes/position_target.tscn")

var _position_targets: Dictionary = {}


func _ready():
	for _unit in get_tree().get_nodes_in_group("unit"):
		if not _unit is Unit:
			continue

		var unit = _unit as Unit
		unit.on_move_target_reached.connect(func(): on_move_target_reached(unit))
		_units.append(unit)
		# TODO: Try using the unit object directly instead of stringifying the instance id
		_position_targets[str(unit.get_instance_id())] = _position_target_scene.instantiate()
		add_child(get_pos_target(unit))

	print_debug("Units: ", len(_units))
	update_position_targets_visibility()


func _process(delta):
	if _mouse.right:
		for pos_target in _position_targets.values():
			pos_target.move_towards_mouse_cursor()


func _input(event):
	if event is InputEventMouseButton:
		update_position_targets_visibility()
		if _mouse.left and _mouse.right:
			update_move_target()


func on_move_target_reached(unit: Unit):
	get_pos_target(unit).visible = false


func update_position_targets_visibility():
	for unit in _units:
		var target = get_pos_target(unit)
		target.visible = _mouse.right or not unit._has_reached_move_target
		# target.process_mode = PROCESS_MODE_INHERIT if visible else PROCESS_MODE_DISABLED


func update_move_target():
	# if not _mouse.left and not _mouse.right:
	# 	return

	for unit in _units:
		# TODO: Check if target position is movable to
		var position_target = get_pos_target(unit)
		if not position_target:
			printerr("Position target for the unit not found", unit, position_target)
			print_debug("Position targets: ", _position_targets.keys())
			continue
		unit.move_target = position_target.position
		position_target.visible = true


func get_pos_target(unit: Unit) -> PositionTarget:
	return _position_targets[str(unit.get_instance_id())]
