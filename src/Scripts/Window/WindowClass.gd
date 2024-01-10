extends Node2D
class_name WindowDisplay


const _ENTER_Y_OFFSET : float = 43.5
const _WINDOW_TEXT_LIMIT_OFFSET : float = 200

var _writing : bool = false

var _moving : bool = false
var _resizing : bool = false

var _windowSprite : Sprite2D = Sprite2D.new()
var _windowText : Label = Label.new()
var _taskbarText : String

var _targetScaleX : float
var _targetScaleY : float
var _tResize : float
var _tMove : float
var _targetPosition : Vector2
var _elapsedTimeResize : float
var _elapsedTimeMove : float
var _originalWindowTextSize : Vector2

# CONSTRUCTOR

func _init(windowTexture : CompressedTexture2D, font : FontFile, fontSize : int, fontColor : Color):
	self._windowSprite.texture = windowTexture
	add_child(self._windowSprite)

	WindowUtils.configureWindowTextObj(self._windowText, font, fontSize, self._windowSprite.get_rect(), fontColor)
	self._windowSprite.add_child(self._windowText)
	self._originalWindowTextSize = self._windowText.size


# UPDATE PER FRAME

func _process(delta):
	if self._writing:
		self._checkWritingEnd()

	if self._resizing:
		self._scale(delta)

	if self._moving:
		self._reposition(delta)

	if self._textIsBiggerThanWindow():
		self._eraseBeggining()


# PUBLIC METHODS

func resize(widthPercentage : float, heightPercentage : float, t : float):
	self._targetScaleX = self._windowSprite.scale.x * widthPercentage
	self._targetScaleY = self._windowSprite.scale.y * heightPercentage
	self._tResize = t
	self._resizing = true


func moveTo(pos : Vector2, t : float):
	self._targetPosition = pos
	self._tMove = t
	self._moving = true


func writeAnimatedText(text : String):
	self._windowText.visible_characters = len(self._windowText.text)
	self._windowText.text += text
	self._writing = true
	print(self._windowText.visible_characters)


func addChild(child : Object):
	self._windowSprite.add_child(child)


func windowTextToOriginalSize():
	self._windowText.size = self._originalWindowTextSize


func getSpriteTexture():
	return self._windowSprite.texture


func getTaskbarText():
	return self._taskbarText


func getSpriteRect():
	return self._windowSprite.get_rect()


func getSpriteHeight():
	return self._windowSprite.texture.get_height()


func getEnterYOffset():
	return self._ENTER_Y_OFFSET


func getWindowText():
	return self._windowText.text


func setTaskbarText(text : String):
	self._taskbarText = text


func setWindowText(text : String):
	self._windowText.text = text
	self._windowText.visible_characters = -1



func isWriting():
	return self._writing


# PRIVATE METHODS


func _scale(delta : float):
	var tPerFrame : float = self._tResize * delta
	self._elapsedTimeResize += tPerFrame
	self._windowSprite.scale.x = lerpf(self._windowSprite.scale.x, self._targetScaleX, tPerFrame)
	self._windowSprite.scale.y = lerpf(self._windowSprite.scale.y, self._targetScaleY, tPerFrame)
	self._checkActionFinished(self._tResize)


func _reposition(delta : float):
	var tPerFrame : float = self._tMove * delta
	self._elapsedTimeMove += tPerFrame
	position = position.lerp(self._targetPosition, tPerFrame)
	self._checkActionFinished(self._tMove)


func _eraseBeggining():
	var charsToDelete : int = self._windowText.text.find("\n") + 1
	self._windowText.text = self._windowText.text.erase(0, charsToDelete)


func _isInsideWindow(pos : Vector2):
	return self._windowSprite.get_rect().has_point(pos)


func _textIsBiggerThanWindow():
	return self._windowText.size.y + self._WINDOW_TEXT_LIMIT_OFFSET >= self.getSpriteHeight()


func _checkActionFinished(t : float):
	if self._elapsedTimeResize >= t and t == self._tResize:
		self._resizing = false
		self._elapsedTimeResize = 0

	if self._elapsedTimeMove >= t and t == self._tMove:
		self._moving = false
		self._elapsedTimeMove = 0


func _checkWritingEnd():
	if self._windowText.visible_characters >= len(self._windowText.text):
		self._windowText.visible_characters = -1
		self._writing = false
		return
	print(self._windowText.visible_characters)

	self._windowText.visible_characters += 3


# Used to verify if the node inherits from class WindowDisplay
func _get(property):
	return true
