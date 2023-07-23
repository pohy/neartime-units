@tool
extends Control
class_name MouseOver

signal on_change(is_within: bool)

@export var debug: bool = false
@export var update: bool:
	get: return false
	set(_value): queue_redraw()

@export var bounds: RectangleShape2D = null
@export var bounds_rect: Rect2:
	get:
		if bounds == null:
			return Rect2(Vector2.ZERO, Vector2.ZERO)
		return Rect2(bounds.size * 0.5, window_size - bounds.size)

@onready var mouse: Mouse = $Mouse

var is_within: bool = false
var window_size = Vector2(0, 0)

func _ready():
	window_size = Vector2(get_viewport().get_size())

func _input(event):
	if not event is InputEventMouseMotion:
		return
	is_within = bounds_rect.has_point(mouse.pos)
	on_change.emit(is_within)

func _draw():
	if not debug or bounds == null:
		return

	draw_rect(bounds_rect, Color(0.1, 0.3, 0.2, 0.3))

func _get_configuration_warnings():
	var warnings = []
	if bounds == null:
		warnings.append("Bounds not set.")
	return warnings
