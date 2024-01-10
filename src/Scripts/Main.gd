extends Node2D

@onready var taskbar : Taskbar = $Taskbar


func isWindowDisplay(node : Node):
	return node.get("")


func _on_start_timeout():
	for i in range(7):
		var window : Terminal = Terminal.new()
		window.position = Vector2(520,307) + Vector2(i * 20, 0)
		add_child(window)


func _on_child_entered_tree(node):
	if isWindowDisplay(node):
		taskbar.addNewWindow(node)


func _on_child_exiting_tree(node):
	if isWindowDisplay(node):
		taskbar.removeWindow(node)
