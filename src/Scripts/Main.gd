extends Node2D

var windows : Array[WindowDisplay]

@onready var taskbar : Taskbar = $Taskbar


func isWindowDisplay(node : Node):
	return node is WindowDisplay

func isTaskbarWindow(node : Node):
	return node is TaskbarWindow


func freeCorrespondentWindow(id : int):
	for w in windows:
		if w.get_instance_id() == id:
			windows.erase(w)
			w.queue_free()

func _on_start_timeout():
	for i in range(7):
		var window : Terminal = Terminal.new()
		window.position = Vector2(520,307) + Vector2(i * 20, 0)
		add_child(window)
		windows.append(window)


func _on_child_entered_tree(node):
	if isWindowDisplay(node):
		taskbar.onAddNewWindow(node)


func _on_child_exiting_tree(node):
	if isWindowDisplay(node):
		windows.erase(node)
		taskbar.onRemoveWindow(node.get_instance_id())


func _on_taskbar_child_exiting_tree(node):
	if isTaskbarWindow(node):
		freeCorrespondentWindow(node.id)
