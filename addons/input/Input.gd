extends Node
class_name Inpt

var primary: bool = false

var _dir: Vector2 = Vector2(0, 0)
@export var dir: Vector2:
	get:
		return _dir


func _input(_event):
	if _event is InputEventKey:
		process_key_event(_event)

func process_key_event(event: InputEventKey):
	if event.is_pressed():
		if event.keycode == KEY_W:
			_dir.y = -1
		elif event.keycode == KEY_S:
			_dir.y = 1
		elif event.keycode == KEY_A:
			_dir.x = -1
		elif event.keycode == KEY_D:
			_dir.x = 1
	elif event.is_released():
		if event.keycode == KEY_W:
			_dir.y = 0
		elif event.keycode == KEY_S:
			_dir.y = 0
		elif event.keycode == KEY_A:
			_dir.x = 0
		elif event.keycode == KEY_D:
			_dir.x = 0
