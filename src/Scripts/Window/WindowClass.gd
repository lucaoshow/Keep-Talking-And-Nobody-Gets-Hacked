extends Node2D
class_name WindowDisplay


const _ENTER_Y_OFFSET : float = 43.5
const _WINDOW_TEXT_LIMIT_OFFSET : float = 200

var _writing : bool = false

var _moving : bool = false
var _resizing : bool = false

var _windowSprite : Sprite2D = Sprite2D.new()
var _windowText : Label = Label.new()

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
	_windowSprite.texture = windowTexture
	add_child(_windowSprite)

	WindowUtils.configureWindowTextObj(_windowText, font, fontSize, _windowSprite.get_rect(), fontColor)
	_windowSprite.add_child(_windowText)
	_originalWindowTextSize = _windowText.size


# UPDATE PER FRAME

func _process(delta):
	if _writing:
		_checkWritingEnd()
	
	if _resizing:
		_scale(delta)

	if _moving:
		_reposition(delta)

	if _textIsBiggerThanWindow():
		_eraseBeggining()


# PUBLIC METHODS

func resize(widthPercentage : float, heightPercentage : float, t : float):
	_targetScaleX = _windowSprite.scale.x * widthPercentage
	_targetScaleY = _windowSprite.scale.y * heightPercentage
	_tResize = t
	_resizing = true


func moveTo(pos : Vector2, t : float):
	_targetPosition = pos
	_tMove = t
	_moving = true


func writeAnimatedText(text : String):
	_windowText.visible_characters = len(_windowText.text)
	_windowText.text += text
	_writing = true
	print(_windowText.visible_characters)


func addChild(child : Object):
	_windowSprite.add_child(child)


func windowTextToOriginalSize():
	_windowText.size = _originalWindowTextSize


func getSpriteRect():
	return _windowSprite.get_rect()


func getSpriteHeight():
	return _windowSprite.texture.get_height()


func getEnterYOffset():
	return _ENTER_Y_OFFSET


func getWindowText():
	return _windowText.text


func setWindowText(text : String):
	_windowText.text = text
	_windowText.visible_characters = -1



func isWriting():
	return _writing


# PRIVATE METHODS


func _scale(delta : float):
	var tPerFrame = _tResize * delta
	_elapsedTimeResize += tPerFrame
	_windowSprite.scale.x = lerpf(_windowSprite.scale.x, _targetScaleX, tPerFrame)
	_windowSprite.scale.y = lerpf(_windowSprite.scale.y, _targetScaleY, tPerFrame)
	_checkActionFinished(_tResize)


func _reposition(delta : float):
	var tPerFrame = _tMove * delta
	_elapsedTimeMove += tPerFrame
	position = position.lerp(_targetPosition, tPerFrame)
	_checkActionFinished(_tMove)


func _eraseBeggining():
	var charsToDelete : int = _windowText.text.find("\n") + 1
	_windowText.text = _windowText.text.erase(0, charsToDelete)


func _isInsideWindow(pos : Vector2):
	return _windowSprite.get_rect().has_point(pos)


func _textIsBiggerThanWindow():
	return _windowText.size.y + _WINDOW_TEXT_LIMIT_OFFSET >= getSpriteHeight()


func _checkActionFinished(t : float):
	if _elapsedTimeResize >= t and t == _tResize:
		_resizing = false
		_elapsedTimeResize = 0

	if _elapsedTimeMove >= t and t == _tMove:
		_moving = false
		_elapsedTimeMove = 0


func _checkWritingEnd():
	if _windowText.visible_characters >= len(_windowText.text):
		_windowText.visible_characters = -1
		_writing = false
		return
	print(_windowText.visible_characters)

	_windowText.visible_characters += 3
