extends Control

class_name Taskbar


var windows : Array[TaskbarWindow]

func displayWindows():
	pass

func addNewWindow(window : WindowDisplay):
	self.windows.append(TaskbarWindow.new(window))
	self.displayWindows()

func removeWindow(window : WindowDisplay):
	self.windows = self.windows.filter(func(w : TaskbarWindow): return w.isActiveWindow(window))
	self.displayWindows()
