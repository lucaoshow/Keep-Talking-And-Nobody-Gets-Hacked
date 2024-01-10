extends Control

class_name Taskbar


const WINDOW_INITIAL_POS : Vector2 = Vector2(125, 0)
const WINDOW_POS_OFFSET : Vector2 = Vector2(155, 0)
const MAX_WINDOWS : int = 5
const PLUS_POS : Vector2 = Vector2(1040, 18)
const PLUS_SCALE : Vector2 = Vector2(1.3, 1.3)

var windows : Array[TaskbarWindow]
var plusTexture : CompressedTexture2D = preload("res://Assets/Taskbar/plus.png")

@onready var plusSprite : Sprite2D = Sprite2D.new()


func _ready():
	plusSprite.visible = false
	plusSprite.texture = plusTexture
	plusSprite.position = PLUS_POS
	plusSprite.scale = PLUS_SCALE
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
			break
		var window = windows[w]
		window.position = windows[w-1].position + WINDOW_POS_OFFSET
		if !window.is_inside_tree():
			self.add_child(window)

	plusSprite.visible = amount > MAX_WINDOWS

func _removeFromScene(window : WindowDisplay):
	for i in range(windows.size() - 1, -1, -1):
		var w = windows[i]
		if w.isActiveWindow(window):
			continue
		windows.remove_at(i)
		w.queue_free()
		break
