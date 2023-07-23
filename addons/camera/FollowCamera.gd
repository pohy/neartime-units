@tool
extends Node3D
class_name FollowCamera

@export var target: Node3D = null
@export var zoom_out: float = 10
@export var max_zoom_out_speed: float = 1
@export var fixed: bool = false

@onready var speed: Speed = $Speed
@onready var mouse_over: MouseOver = $MouseOver
@export var camera: Camera3D = null
@onready var shaker: Shaker = %Shaker

var _target_position: Vector3 = Vector3.ZERO
var _inital_fov: float = 0
var _current_fov: float = 0
var _target_fov: float = 0
var _player_speed01: float = 0


func _ready() -> void:
	_inital_fov = camera.fov
	_current_fov = camera.fov
	shaker.target_node = camera
	shaker.target_property = "position"
	camera = $Camera3D if camera == null else camera


func _physics_process(delta: float) -> void:
	follow_target()

	if not speed or Engine.is_editor_hint():
		return

	update_fov(delta)
	maybe_start_shaking()


func _get_configuration_warnings():
	var warnings := []
	if target == null:
		warnings.append("No target node set.")
	if shaker == null:
		warnings.append("No shaker node set.")
	if camera == null:
		warnings.append("No Camera3D node set.")
	return warnings


func follow_target() -> void:
	if target == null:
		return
	if not fixed and mouse_over and mouse_over.is_within:
		return
	_target_position = target.global_transform.origin
	global_transform.origin = _target_position


func update_fov(delta: float) -> void:
	# var mix = EasingFunctions.ease_in_out_expo(0, 1, _player_speed01)
	# camera.fov = _inital_fov + (zoom_out * speed.speed01)
	_target_fov = _inital_fov + zoom_out * _player_speed01
	_current_fov = EasingFunctions.ease_out_quad(_current_fov, _target_fov, delta)

	camera.fov = _current_fov

	# print_debug("🎥 speed.speed01: " + str(speed.speed_avg))
	# print_debug("mix: " + str(mix))
	# print_debug("camera.fov: " + str(camera.fov))


func maybe_start_shaking() -> void:
	if shaker == null:
		return
	if _player_speed01 < 0.7:
		return
	if not shaker.is_shaking():
		shaker.start()
