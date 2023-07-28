class_name Unit
extends CharacterBody3D

signal on_move_target_reached

enum State {
	IDLE,
	MOVING,
	ATTACKING,
}
var _state: State = State.IDLE

@onready var _body: CollisionShape3D = $CollisionShape3D
@onready var _debug_sphere: MeshInstance3D = $DebugSphere
@onready var _position_target: PositionTarget = $PositionTarget
@onready var _position_target_preview: PositionTarget = $PositionTargetPreview

@export var speed: float = 1.0
@export var rotation_speed: float = 1.0
@export var move_target: Vector3 = Vector3.ZERO


func _ready():
	_position_target_preview._material.albedo_texture = load(
		"res://addons/kenney_prototype_textures/green/texture_01.png"
	)


func _process(delta):
	if Engine.is_editor_hint():
		return

	_debug_sphere.global_position = move_target

	match _state:
		State.MOVING:
			state_moving()
		State.IDLE:
			state_idle()
		State.ATTACKING:
			printerr("Atacking not implemented")


func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	self.move_and_slide()


func state_idle():
	self.velocity = Vector3.ZERO


func state_moving():
	var target_dir = move_target - position

	if target_dir.length_squared() <= 0.26:
		_state = State.IDLE
		_position_target._state = PositionTarget.State.Hidden
		on_move_target_reached.emit()
		return

	var input_dir = target_dir.normalized()
	input_dir.y = 0

	# Orient body in the direction of movement
	var next_look_at = self.position - input_dir
	next_look_at.y = _body.position.y
	_body.look_at(next_look_at, Vector3.UP)
	self.velocity = input_dir * speed


func preview_move_target(pos: Vector3):
	print_debug("preview_move_target", pos)
	_position_target_preview._state = PositionTarget.State.Preview
	_position_target_preview.global_position = pos


func clear_move_target_preview():
	print_debug("clear_move_target_preview")
	_position_target_preview._state = PositionTarget.State.Hidden
	_position_target_preview.global_position = self.global_position


func move_to(pos: Vector3):
	print_debug("move_to", pos)
	_state = State.MOVING
	move_target = pos
	_position_target_preview._state = PositionTarget.State.Hidden
	_position_target._state = PositionTarget.State.Active
	_position_target.global_position = pos
	clear_move_target_preview()
