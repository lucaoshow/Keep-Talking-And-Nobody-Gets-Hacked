extends Node2D

@onready var firstWindow : Terminal = Terminal.new()
@onready var taskbar : Taskbar = $Taskbar


func _on_start_timeout():
	firstWindow.position = Vector2(520,307) # idk random position to test
	add_child(firstWindow)


func _on_child_entered_tree(node):
	taskbar.AddNewWindow(node)


func _on_child_exiting_tree(node):
	taskbar.RemoveWindow(node)
