extends Node

var _units: Array[CharacterBody3D] = []
var _position_target_scene: PackedScene = preload("res://scenes/position_target.tscn")

var _position_targets: Dictionary = {}


func _ready():
	for u in get_tree().get_nodes_in_group("unit"):
		if not u is CharacterBody3D:
			continue

		_units.append(u)
		_position_targets[u] = _position_target_scene.instantiate()
		add_child(_position_targets[u])

	print_debug("Units: ", len(_units))
