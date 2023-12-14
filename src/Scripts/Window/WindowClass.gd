extends Node2D
class_name WindowDisplay

const _TERMINAL_PATH : String = "C:\\WINDOWS\\System32\\"

enum States {IDLE = 1, RESIZING, MOVING}
var _currentState : States = States.IDLE

var _windowSprite : Sprite2D = Sprite2D.new()
var _typingSpace : LineEdit = LineEdit.new()
var _windowText : Label = Label.new()

var _targetScaleX : float
var _targetScaleY : float
var _t : float
var _targetPosition : Vector2
var _elapsedTime : float

# CONSTRUCTOR

func _init(widthScale : float, heightScale : float, typeable : bool = true,
			windowTexture : CompressedTexture2D = preload("res://Assets/Terminal/terminal.png"),
			font : FontFile = preload("res://Assets/Terminal/CMD.ttf"), fontSize : int = 18):

	_windowSprite.scale.x = widthScale
	_windowSprite.scale.y = heightScale
	_windowSprite.texture = windowTexture
	add_child(_windowSprite)

	var reference : Rect2 = _windowSprite.get_rect()
	
	WindowUtils.configureWindowTextObj(_windowText, font, fontSize, reference)
	_windowSprite.add_child(_windowText)
	
	if typeable:
		WindowUtils.configureWindowTextObj(_typingSpace, font, fontSize, reference)
		_typingSpace.text = _TERMINAL_PATH
		
		_typingSpace.connect("text_changed", _blockterminalPathErasing)
		_typingSpace.connect("text_submitted", _enterCommand)
		
		_windowSprite.add_child(_typingSpace)

	else:
		_typingSpace.free()


# PUBLIC METHODS

func resize(widthPercentage : float, heightPercentage : float, t : float):
	_targetScaleX = _windowSprite.scale.x * widthPercentage
	_targetScaleY = _windowSprite.scale.y * heightPercentage
	_t = t
	_currentState = States.RESIZING


func moveTo(pos : Vector2, t : float):
	_targetPosition = pos
	_t = t
	_currentState = States.MOVING


# PRIVATE METHODS

func _checkActionFinished():
	if _elapsedTime >= _t:
		_currentState = States.IDLE
		_elapsedTime = 0


func _scale(delta : float):
	var tPerFrame = _t * delta
	_elapsedTime += tPerFrame
	_windowSprite.scale.x = lerpf(_windowSprite.scale.x, _targetScaleX, tPerFrame)
	_windowSprite.scale.y = lerpf(_windowSprite.scale.y, _targetScaleY, tPerFrame)
	_checkActionFinished()


func _reposition(delta : float):
	var tPerFrame = _t * delta
	_elapsedTime += tPerFrame
	position = position.lerp(_targetPosition, tPerFrame)
	_checkActionFinished()


func _resetTerminalText():
	_typingSpace.text = _TERMINAL_PATH
	_typingSpace.caret_column = len(_TERMINAL_PATH)


# UPDATE PER FRAME

func _process(delta):
	if _currentState == States.RESIZING:
		_scale(delta)

	if _currentState == States.MOVING:
		_reposition(delta)


# CALLABLES FOR SIGNALS

func _blockterminalPathErasing(newText : String):
	if len(_typingSpace.text) <= len(_TERMINAL_PATH):
		_resetTerminalText()


func _enterCommand(newText : String):
	_windowText.text += newText + "\n"
	_typingSpace.clear()
	_typingSpace.position.y += _typingSpace.size.y
	_resetTerminalText()
