class_name Mouse
extends Node

signal on_motion
signal on_click

var left: bool = false
var right: bool = false
var pos: Vector2 = Vector2.ZERO
var from_center: Vector2 = Vector2.ZERO
var delta: Vector2 = Vector2.ZERO
var is_moving: bool = false

@onready var window_size: Vector2

var _last_pos: Vector2 = Vector2.ZERO


func _ready():
	window_size = get_viewport().get_size()


func _process(_delta):
	is_moving = false
	delta = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		is_moving = true
		pos = event.position
		from_center = (pos / window_size) * 2 - Vector2.ONE
		delta = event.relative
		_last_pos = pos

		on_motion.emit()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left = event.is_pressed() and not event.is_released()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right = event.is_pressed() and not event.is_released()
		on_click.emit()
