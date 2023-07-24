@tool
class_name MovementControls
extends Node

@export var speed: float = 1.0
@export var camera: Camera3rdPerson

@onready var _input: Inpt = $Input
@onready var _mouse: Mouse = $Mouse

var _character: CharacterBody3D


func _get_configuration_warnings():
	var warnings = []
	if _character == null:
		warnings.append("CharacterBody3D parent is null.")
	# if not camera:
	# 	warnings.append("No camera assigned to the character")
	return warnings


func _ready():
	on_new_parent()


func _process(delta):
	if Engine.is_editor_hint():
		return

	var next_dir = Vector3.ZERO
	var input_dir = Vector3(_input.dir.x, 0, _input.dir.y)
	if not camera:
		next_dir = input_dir
	else:
		next_dir = input_dir
		if _mouse.left and _mouse.right and input_dir.length() < 0.001:
			next_dir = -Vector3.FORWARD
		next_dir = next_dir.rotated(Vector3.UP, camera.look_target.rotation.y)

	_character.velocity = next_dir * speed


func _physics_process(delta):
	if Engine.is_editor_hint():
		return

	_character.move_and_collide(_character.velocity * delta)


func on_new_parent():
	_character = get_parent()
