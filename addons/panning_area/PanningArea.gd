@tool
extends Control
class_name PanningArea

signal active_side_changed(active_side: Vector2)

var window_size = Vector2(0, 0)
var mouse_pos = Vector2(0, 0)
var active_side = Vector2.ZERO
var prev_active_side = Vector2.ZERO

@export var camera: Camera3D = null
@export var debug: bool = true
@export var update: bool:
	get: return false
	set(_value): queue_redraw()

@export_category("Panning Area")
@export var pan_area_rect: RectangleShape2D = null
@export var pan_area: Rect2:
	get:
		if pan_area_rect == null:
			return Rect2(Vector2.ZERO, Vector2.ZERO)
		return Rect2(pan_area_rect.size * 0.5, window_size - pan_area_rect.size)

func _ready():
	window_size = Vector2(get_viewport().get_size())

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		update_current_active_side()

func _gui_input(_event):
	queue_redraw()

func _draw():
	draw_active_rects()

func _get_configuration_warnings():
	var warnings = []
	if pan_area_rect == null:
		warnings.append("pan_area_rect is not set")
	if camera == null:
		warnings.append("camera is not set")
	return warnings

func has_point(point: Vector2) -> bool:
	return !pan_area.has_point(point)

func update_current_active_side():
	active_side = get_active_side()
	if (active_side - prev_active_side).length_squared() > 0:
		emit_signal("active_side_changed", active_side)
		queue_redraw()
	prev_active_side = active_side

func get_active_side() -> Vector2:
	var _active_side = Vector2.ZERO

	if !has_point(mouse_pos):
		return _active_side

	if mouse_pos.x < pan_area.position.x:
		_active_side.x = mouse_pos.x / pan_area.position.x - 1
	elif mouse_pos.x > pan_area.position.x + pan_area.size.x:
		_active_side.x = (mouse_pos.x - pan_area.size.x) / pan_area.position.x - 1

	if mouse_pos.y < pan_area.position.y:
		_active_side.y = mouse_pos.y / pan_area.position.y - 1
	elif mouse_pos.y > pan_area.position.y + pan_area.size.y:
		_active_side.y = (mouse_pos.y - pan_area.size.y) / pan_area.position.y - 1

	# print_debug("active_side: ", _active_side)

	return _active_side

func draw_active_rects():
	if !debug:
		return

	var rects = [
		{
			# Left
			visible = active_side.x < 0,
			opacity = active_side.x,
			rect = Rect2(
				Vector2(0, 0),
				Vector2(pan_area.position.x, window_size.y - pan_area.position.y),
			),
		},
		{
			# Top
			visible = active_side.y < 0,
			opacity = active_side.y,
			rect = Rect2(
				Vector2(pan_area.position.x, 0),
				Vector2(window_size.x - pan_area.position.x, pan_area.position.y),
			),
		},
		{
			# Right
			visible = active_side.x > 0,
			opacity = active_side.x,
			rect = Rect2(
				Vector2(pan_area.position.x + pan_area.size.x, pan_area.position.y),
				Vector2(window_size.x - pan_area.position.x - pan_area.size.x, window_size.y - pan_area.position.y),
			),
		},
		{
			# Bottom
			visible = active_side.y > 0,
			opacity = active_side.y,
			rect = Rect2(
				Vector2(0, pan_area.size.y + pan_area.position.y),
				Vector2(window_size.x - pan_area.position.x, window_size.y - pan_area.position.y - pan_area.size.y),
			),
		},
	]
	# print_debug("rects: ", rects)
	for rect in rects:
		if !rect.visible and not Engine.is_editor_hint():
			continue
		var opacity = max(0.2, min(0.8, abs(rect.opacity)))
		draw_rect(rect.rect, Color(0.3, 0.8, 0.3, opacity))