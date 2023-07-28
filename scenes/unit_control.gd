extends Node

@onready var _mouse: Mouse = $Mouse
@onready var _world_cursor: WorldCursor = $WorldCursor

var _units: Array[Unit] = []


func _ready():
	_world_cursor._mouse = _mouse
	for _unit in get_tree().get_nodes_in_group("unit"):
		if not _unit is Unit:
			continue

		var unit = _unit as Unit
		unit.on_move_target_reached.connect(func(): on_move_target_reached(unit))
		_units.append(unit)

	print_debug("Units: ", len(_units))


# func _process(delta):
# 	if _mouse.right:
# 		for unit in _units:
# 			# TODO: We'll need to coordinate positioning for multiple units at the same time
# 			unit.preview_move_target(_world_cursor.pos)
# 	if _mouse.right_released:
# 		for unit in _units:
# 			unit.clear_move_target_preview()
# 	if _mouse.right and _mouse.left_released:
# 		for unit in _units:
# 			unit.move_to(_world_cursor.pos)


func _input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		for unit in _units:
			if _mouse.right and not _mouse.left:
				unit.preview_move_target(_world_cursor.pos)
			if _mouse.right_released:
				unit.clear_move_target_preview()
			if _mouse.right and _mouse.left_released:
				unit.move_to(_world_cursor.pos)


func on_move_target_reached(unit: Unit):
	print("Move target reached", unit)
