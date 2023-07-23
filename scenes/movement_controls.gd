@tool
extends Node

@export var speed: float = 1.0
@export var camera: Camera3rdPerson

@onready var _character: CharacterBody3D = get_parent()
@onready var _input: Inpt = $Input


func _get_configuration_warnings():
	var warnings = []
	if _character == null:
		warnings.append("CharacterBody3D parent is null.")
	# if not camera:
	# 	warnings.append("No camera assigned to the character")
	return warnings


func _process(delta):
	if Engine.is_editor_hint():
		return

	var next_dir = Vector3.ZERO
	var input_dir = Vector3(_input.dir.x, 0, _input.dir.y)
	if not camera:
		next_dir = input_dir
	else:
		var dir_camera = input_dir.rotated(Vector3.UP, camera.look_target.rotation.y)
		next_dir = dir_camera

	_character.velocity = next_dir * speed


func _physics_process(delta):
	if Engine.is_editor_hint():
		return

	_character.move_and_slide()
