@tool
extends Node3D

@export var camera: Camera3rdPerson
@export var controls: MovementControls
@export var possesable: Array[CharacterBody3D]

var _possesed: CharacterBody3D = null
var _index: int = 0


func _ready():
	Engine.max_fps = 60

	if Engine.is_editor_hint():
		return

	var possesed = controls.get_parent()
	if possesed is CharacterBody3D:
		_possesed = possesed

	var i = 0
	for p in get_tree().get_nodes_in_group("possesable"):
		if p.has_node(controls.get_path_to(controls)):
			possesable.append(p)
			if p.get_instance_id() == _possesed.get_instance_id():
				_index = i
		i += 1

func _process(delta):
	Engine.max_fps = 60


func _input(event):
	if not controls:
		return

	if not _possesed:
		print("No possesable character found")
		return

	if event.is_action("ui_cancel"):
		get_tree().quit()