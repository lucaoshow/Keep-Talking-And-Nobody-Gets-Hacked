extends Node2D
class_name WindowDisplay

var placeholder : Label

const _TERMINAL_PATH : String = "C:\\WINDOWS\\System32>"
const _WINDOW_LIMIT_OFFSET : float = 100

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
var _erasedChars : Array[String]
var _OnEnterCommandYOffset : float
var _lastTextLength : int = len(_TERMINAL_PATH)


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
		
		_typingSpace.connect("text_changed", _checkTypedChar)
		_typingSpace.connect("text_submitted", _enterCommand)
		
		_windowSprite.add_child(_typingSpace)
		
		_OnEnterCommandYOffset = _windowText.size.y
		
		placeholder = Label.new()
		WindowUtils.configureWindowTextObj(placeholder, font, fontSize, reference, true)
		placeholder.text = "clear"
		
		_windowSprite.add_child(placeholder)
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
	_typingSpace.text = _TERMINAL_PATH + _typingSpace.text.substr(len(_TERMINAL_PATH) - 1)
	_typingSpace.caret_column = len(_typingSpace.text)


func _isInsideWindow(pos : Vector2):
	return _windowSprite.get_rect().has_point(pos)


func _textIsBiggerThanWindow():
	var textRect = _windowText.get_rect()
	var windowRect = _windowSprite.get_rect() 
	return textRect.position.y + textRect.size.y + _WINDOW_LIMIT_OFFSET >= windowRect.position.y + windowRect.size.y


func _erasePlaceholder(index : int):
	if index < len(placeholder.text):
		_erasedChars.append(placeholder.text[index])
		placeholder.text[index] = "_"


func _returnPlaceholderChar(index : int):
	if index < len(placeholder.text):
		placeholder.text[index] = _erasedChars[-1]
		_erasedChars.pop_back()
		


# UPDATE PER FRAME

func _process(delta):
	if _currentState == States.RESIZING:
		_scale(delta)

	if _currentState == States.MOVING:
		_reposition(delta)


# EVENT LISTENER

func _input(event):
	if event is InputEventMouseButton and _isInsideWindow(to_local(event.position)) and _typingSpace:
		_typingSpace.grab_focus()
		_typingSpace.caret_column = len(_typingSpace.text)


# CALLABLES FOR SIGNALS

func _checkTypedChar(newText : String):
	if !_typingSpace.text.begins_with(_TERMINAL_PATH):
		_resetTerminalText()
		return

	var pathTotalChars : int = len(_TERMINAL_PATH) - 1
	var pathLength : int = len(_TERMINAL_PATH)
	var lastChar : String = _typingSpace.text[-1]
	var charIndex : int = _typingSpace.text.rfind(lastChar)

	var newTextLength = len(newText)
	if _lastTextLength > newTextLength:
		_returnPlaceholderChar(charIndex - pathTotalChars)
		
	elif charIndex > pathTotalChars:
		_erasePlaceholder(charIndex - pathLength)

	_lastTextLength = newTextLength


func _enterCommand(newText : String):
	_typingSpace.clear()
	if _textIsBiggerThanWindow():
		var charsToDelete : int = _windowText.text.find("\n") + 1
		_windowText.text = _windowText.text.erase(0, charsToDelete)
	else:
		_typingSpace.position.y += _OnEnterCommandYOffset
		placeholder.position.y += _OnEnterCommandYOffset

	_windowText.text += newText + "\n"
	placeholder.text = "clear" # remove this line in order to stop setting "clear" as the suggested command
	_erasedChars.clear()
