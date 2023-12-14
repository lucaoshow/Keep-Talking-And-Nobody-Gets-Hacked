extends Node2D
class_name WindowDisplay


const _WINDOW_LIMIT_OFFSET : float = 100

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


# CONSTRUCTOR

func _init(widthScale : float, heightScale : float,
			windowTexture : CompressedTexture2D,
			font : FontFile, fontSize : int, fontColor):

	_windowSprite.scale.x = widthScale
	_windowSprite.scale.y = heightScale
	_windowSprite.texture = windowTexture
	add_child(_windowSprite)

	WindowUtils.configureWindowTextObj(_windowText, font, fontSize, _windowSprite.get_rect(), fontColor)
	_windowSprite.add_child(_windowText)


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


func getSpriteRect():
	return _windowSprite.get_rect()


func getEnterYOffset():
	return _windowText.size.y


func getWindowText():
	return _windowText.text


func setWindowText(text : String):
	_windowText.text = text


func addChild(child : Object):
	_windowSprite.add_child(child)


func textIsBiggerThanWindow():
	var textRect = _windowText.get_rect()
	var windowRect = _windowSprite.get_rect() 
	return textRect.position.y + textRect.size.y + _WINDOW_LIMIT_OFFSET >= windowRect.position.y + windowRect.size.y


# PRIVATE METHODS

func _checkActionFinished(t : float):
	if _elapsedTimeResize >= t and t == _tResize:
		_resizing = false
		_elapsedTimeResize = 0

	if _elapsedTimeMove >= t and t == _tMove:
		_moving = false
		_elapsedTimeMove = 0


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


func _isInsideWindow(pos : Vector2):
	return _windowSprite.get_rect().has_point(pos)


# UPDATE PER FRAME

func _process(delta):
	if _resizing:
		_scale(delta)

	if _moving:
		_reposition(delta)
