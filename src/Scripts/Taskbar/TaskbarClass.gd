extends Control

class_name Taskbar


const _WINDOW_INITIAL_POS : Vector2 = Vector2(125, 0)
const _WINDOW_POS_OFFSET : Vector2 = Vector2(155, 0)
const _MAX_WINDOWS : int = 5
const _PLUS_POS : Vector2 = Vector2(1040, 18)
const _PLUS_SCALE : Vector2 = Vector2(1.3, 1.3)

static var windows : Array[TaskbarWindow]
var _plusTexture : CompressedTexture2D = preload("res://Assets/Taskbar/plus.png")

@onready var _plusSprite : Sprite2D = Sprite2D.new()


func _ready():
	self._plusSprite.visible = false
	self._plusSprite.texture = self._plusTexture
	self._plusSprite.position = self._PLUS_POS
	self._plusSprite.scale = self._PLUS_SCALE
	self.add_child(self._plusSprite)


# EVENT LISTENERS

static func onCloseWindow(taskWindow : TaskbarWindow):
	windows = windows.filter(func(w : TaskbarWindow): return w.id != taskWindow.id)
	taskWindow.queue_free()


func onAddNewWindow(window : WindowDisplay):
	self.windows.append(TaskbarWindow.new(window))
	self._displayWindows()


func onRemoveWindow(id : int):
	self._freeCorrespondentTaskWindow(id)
	self._displayWindows()


# PRIVATE METHODS

func _displayWindows():
	var amount = len(self.windows)
	if !amount:
		return

	var startIndex = amount - 1

	windows[startIndex].position = self._WINDOW_INITIAL_POS
	if !self.windows[startIndex].is_inside_tree():
		self.add_child(self.windows[startIndex])

	for w in range(startIndex - 1, -1, -1):
		if w == self._MAX_WINDOWS:
			break
		var window = windows[w]
		window.position = windows[w-1].position + self._WINDOW_POS_OFFSET
		if !window.is_inside_tree():
			self.add_child(window)

	self._plusSprite.visible = amount > self._MAX_WINDOWS


func _freeCorrespondentTaskWindow(id : int):
	for i in range(self.windows.size() - 1, -1, -1):
		if windows[i].id == id:
			var window : TaskbarWindow = windows[i]
			windows.remove_at(i)
			window.queue_free()
			break
