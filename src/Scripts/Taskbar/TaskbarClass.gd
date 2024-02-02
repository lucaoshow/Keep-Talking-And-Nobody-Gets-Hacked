extends Control

class_name Taskbar


const _WINDOW_INITIAL_POS : Vector2 = Vector2(125, 0)
const _WINDOW_POS_OFFSET : Vector2 = Vector2(155, 0)
const _MAX_WINDOWS : int = 6
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


# PUBLIC METHODS

func disableCloseButton(window : WindowDisplay):
	for i in range(windows.size() - 1, -1, -1):
		if windows[i].id == window.get_instance_id():
			windows[i].freeCloseButton()
			break


func toggleWindow(w : WindowDisplay):
	var id : int = w.get_instance_id()
	for i in range(windows.size() - 1, -1, -1):
		if windows[i].id == id:
			var window : TaskbarWindow = windows[i]
			windows.remove_at(i)
			window.queue_free()
			return
	self.onAddNewWindow(w)



# EVENT LISTENERS

static func onCloseWindow(taskWindow : TaskbarWindow):
	windows = windows.filter(func(w : TaskbarWindow): return w.id != taskWindow.id)
	taskWindow.queue_free()


func onAddNewWindow(window : WindowDisplay):
	windows.append(TaskbarWindow.new(window))
	self._displayWindows()


func onRemoveWindow(id : int):
	self._freeCorrespondentTaskWindow(id)
	self._displayWindows()


# PRIVATE METHODS

func _displayWindows():
	var amount = windows.size()
	if !amount:
		return

	var startIndex = amount - 1
	var limitIndex : int = startIndex - _MAX_WINDOWS

	windows[startIndex].position = self._WINDOW_INITIAL_POS
	if !windows[startIndex].is_inside_tree():
		self.add_child(windows[startIndex])

	for w in range(startIndex - 1, -1, -1):
		var window = windows[w]
		if w <= limitIndex:
			window.visible = false
			continue
		window.visible = true
		window.position = windows[w+1].position + self._WINDOW_POS_OFFSET
		if !window.is_inside_tree():
			self.add_child(window)

	self._plusSprite.visible = amount > self._MAX_WINDOWS


func _freeCorrespondentTaskWindow(id : int):
	for i in range(windows.size() - 1, -1, -1):
		if windows[i].id == id:
			var window : TaskbarWindow = windows[i]
			windows.remove_at(i)
			window.queue_free()
			break
