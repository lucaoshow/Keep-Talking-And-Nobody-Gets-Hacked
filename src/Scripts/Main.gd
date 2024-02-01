extends Node2D

var windows : Array[WindowDisplay]

@onready var taskbar : Taskbar = $Taskbar
@onready var loadingWindow = $LoadingWindow
@onready var hacker : Hacker = Hacker.new()


func hackerEntered():
	taskbar.disableCloseButton(hacker)


func startLoadingWindow():
	loadingWindow.startLoading()
	loadingWindow.timeEnding.connect(hacker.onTimeEnding)


func terminalOpened():
	hacker.onPlayerOpenTerminal()

func _on_start_timeout():
	hacker.entered.connect(hackerEntered)
	hacker.start.connect(startLoadingWindow)
	hacker.position = Vector2(520,307)
	add_child(hacker)
	windows.append(hacker)


func isWindowDisplay(node : Node):
	return node is WindowDisplay

func isTaskbarWindow(node : Node):
	return node is TaskbarWindow


func freeCorrespondentWindow(id : int):
	for w in windows:
		if w.get_instance_id() == id:
			windows.erase(w)
			w.queue_free()


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


func _on_button_button_up():
	var commandExecuter = Commands.new()
	var terminal : Terminal = Terminal.new(commandExecuter)
	terminal.entered.connect(terminalOpened)
	terminal.position = Vector2(1000,1000)
	add_child(terminal)
	hacker.setPlayerTerminal(terminal)
