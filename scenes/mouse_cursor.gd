extends Control

@onready var _mouse: Mouse = $Mouse


func _draw():
	print_debug("Mouse pos: " + str(_mouse.pos))
	draw_circle(_mouse.pos, 3, Color.WHITE_SMOKE)
	draw_circle(_mouse.pos, 2, Color.DARK_BLUE)


func _input(event):
	if event is InputEventMouseMotion:
		queue_redraw()
