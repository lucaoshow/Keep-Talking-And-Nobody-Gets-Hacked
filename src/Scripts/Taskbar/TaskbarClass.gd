extends Control

class_name Taskbar


const WINDOW_INITIAL_POS : Vector2 = Vector2(125, 0)
const WINDOW_POS_OFFSET : Vector2 = Vector2(155, 0)
const MAX_WINDOWS : int = 5

var windows : Array[TaskbarWindow]
var plusTexture : CompressedTexture2D = preload("res://Assets/Taskbar/plus.png")

@onready var plusSprite : Sprite2D = Sprite2D.new()


func _ready():
	plusSprite.visible = false
	plusSprite.texture = plusTexture
	plusSprite.position = Vector2(900, 10)
	self.add_child(plusSprite)


func addNewWindow(window : WindowDisplay):
	self.windows.append(TaskbarWindow.new(window))
	self._displayWindows()


func removeWindow(window : WindowDisplay):
	self._removeFromScene(window)
	self._displayWindows()


func _displayWindows():
	var amount = len(windows)
	if !amount:
		return

	windows[0].position = WINDOW_INITIAL_POS
	if !windows[0].is_inside_tree():
		self.add_child(windows[0])

	for w in range(1, amount):
		if w > MAX_WINDOWS:
			plusSprite.show()
		var window = windows[w]
		window.position = windows[w-1].position + WINDOW_POS_OFFSET
		if !window.is_inside_tree():
			self.add_child(window)


func _removeFromScene(window : WindowDisplay):
	for i in range(windows.size() - 1, -1, -1):
		var w = windows[i]
		if w.isActiveWindow(window):
			continue
		windows.remove_at(i)
		w.queue_free()
		break
