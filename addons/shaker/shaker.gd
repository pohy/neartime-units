@icon("res://addons/shaker/shaker.svg")
class_name Shaker
extends Node

## The node to target. Defaults to parent.
@export var target_node: Node;
## The property to shake.
@export var target_property: StringName = "global_position";
## Minimum value for int/float variables (or 4th dimension).
@export var min_value: float = 0.0;
## Maximum value for int/float variables (or 4th dimension).
@export var max_value: float = 1.0;
## Minimum x value for vectors.
@export var min_value_x: float = 0.0;
## Maximum x value for vectors..
@export var max_value_x: float = 5.0;
## Minimum y value for vectors.
@export var min_value_y: float = 0.0;
## Maximum y value for vectors.
@export var max_value_y: float = 5.0;
## Minimum z value for vectors.
@export var min_value_z: float = 0.0;
## Maximum z value for vectors.
@export var max_value_z: float = 5.0;
## Shake until manually disabled.
@export var constant: bool = false;
## Start automatically when ready.
@export var auto_start: bool = false;
## Shake duration (seconds). Only applies if constant == false.
@export_range(0.0, 3600.0, 0.01) var duration: float = 0.8;
## Shake interval (seconds). How often shake happens.
@export_range(0.0, 30.0) var interval: float = 0.025;
## Shake fall off curve. Only applies if constant == false.
@export var fall_off: Curve;
# internal variables
var timer: Timer = Timer.new();
# original value of target_property
var origin
# target ytpe
var target_type
# internal interval
var increment: float = 0.0

func _ready() -> void:
	if !target_node: target_node = get_parent();

	origin = target_node.get(target_property);

	target_type = typeof(target_node.get(target_property))

	if fall_off == null:
		fall_off = Curve.new()

	add_child(timer);
	timer.wait_time = duration;
	timer.timeout.connect(stop);

	set_process(var_is_valid(target_node, target_property) and constant);

	if auto_start: start();

func var_is_valid(node: Node, property: String) -> bool:
	return property in node;

func start(time_sec: float = -1.0) -> void:
	if not var_is_valid(target_node, target_property):
		print("%s does not have a variable called %s" % [target_node, target_property])
		return
	timer.start(time_sec);
	origin = target_node.get(target_property);
	set_process(true);

func stop() -> void:
	timer.stop();
	target_node.set(target_property, origin);
	set_process(false);

func _process(_delta: float) -> void:
	# shake interval
	increment += _delta
	if increment >= interval:
		increment = 0.0

		# shake
		match target_type:
			TYPE_INT:
				target_node.set(target_property,
					origin + int(randf_range(min_value, max_value) * get_curve_interpolation(fall_off, duration, timer.time_left, constant))
					);

			TYPE_FLOAT:
				target_node.set(target_property,
					origin + randf_range(min_value, max_value) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)
					);

			TYPE_VECTOR2I:
				target_node.set(target_property, origin + Vector2i(
					int(randf_range(min_value_x, max_value_x) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)),
					int(randf_range(min_value_y, max_value_y) * get_curve_interpolation(fall_off, duration, timer.time_left, constant))
					));

			TYPE_VECTOR2:
				target_node.set(target_property, origin + Vector2(
					randf_range(min_value_x, max_value_x) * get_curve_interpolation(fall_off, duration, timer.time_left, constant),
					randf_range(min_value_y, max_value_y) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)
					));

			TYPE_VECTOR3I:
				target_node.set(target_property, origin + Vector3i(
					int(randf_range(min_value_x, max_value_x) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)),
					int(randf_range(min_value_y, max_value_y) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)),
					int(randf_range(min_value_z, max_value_z) * get_curve_interpolation(fall_off, duration, timer.time_left, constant))
					));

			TYPE_VECTOR3:
				target_node.set(target_property, Vector3(
					randf_range(min_value_x, max_value_x) * get_curve_interpolation(fall_off, duration, timer.time_left, constant),
					randf_range(min_value_y, max_value_y) * get_curve_interpolation(fall_off, duration, timer.time_left, constant),
					randf_range(min_value_z, max_value_z) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)
					));

			TYPE_VECTOR4I:
				target_node.set(target_property, Vector4i(
					int(randf_range(min_value_x, max_value_x) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)),
					int(randf_range(min_value_y, max_value_y) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)),
					int(randf_range(min_value_z, max_value_z) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)),
					int(randf_range(min_value, max_value) * get_curve_interpolation(fall_off, duration, timer.time_left, constant))
					));

			TYPE_VECTOR4:
				target_node.set(target_property, Vector4(
					randf_range(min_value_x, max_value_x) * get_curve_interpolation(fall_off, duration, timer.time_left, constant),
					randf_range(min_value_y, max_value_y) * get_curve_interpolation(fall_off, duration, timer.time_left, constant),
					randf_range(min_value_z, max_value_z) * get_curve_interpolation(fall_off, duration, timer.time_left, constant),
					randf_range(min_value, max_value) * get_curve_interpolation(fall_off, duration, timer.time_left, constant)
					));

			_:
				print_debug("Unmatched var type");

func get_curve_interpolation(curve: Curve, max_time: float, time_left: float, _constant: bool) -> Variant:
	if !_constant:
		return 1 - curve.sample(time_left / max_time);
	else:
		return 1;

func is_shaking() -> bool:
	return not timer.is_stopped()
