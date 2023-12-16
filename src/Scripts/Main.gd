extends Node2D

@onready var firstWindow : Terminal = Terminal.new()


func _on_start_timeout():
	firstWindow.position = Vector2(520,307) # idk random position to test
	add_child(firstWindow)
