extends Node2D

@onready var firstWindow : Terminal = Terminal.new(1, 1)


func _on_start_timeout():
	firstWindow.position = Vector2(520,307) # idk random position to test
	add_child(firstWindow)
	$Move.start()
	$Resize.start()


func _on_resize_timeout():
	firstWindow.resize(randf_range(0.3, 2.0), randf_range(0.3, 2.0), randf_range(0.3, 2.0)) # top 10 random values


func _on_move_timeout():
	firstWindow.moveTo(firstWindow.position + Vector2(randf_range(-100, 100), randf_range(-100, 100)), 0.1) # top 11 random values + magical number 0.01
