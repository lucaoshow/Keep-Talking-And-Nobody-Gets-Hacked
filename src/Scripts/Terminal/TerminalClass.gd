extends WindowDisplay
class_name Terminal


const TERMINAL_PATH : String = "C:\\WINDOWS\\System32>"
const _TYPING_SPACE_LIMIT_OFFSET : float = 330

var _commandExecuter : Commands = Commands.new()
var _placeholder : Label = Label.new()
var _typingSpace : LineEdit = LineEdit.new()

var _erasedChars : Array[String]
var _OnEnterCommandYOffset : float
var _lastTextLength : int
var _originalTypingSpacePos : Vector2
var _originalPlaceholderPos : Vector2

func _init():
	const texture : CompressedTexture2D = preload("res://Assets/Terminal/terminal.png")
	const font : FontFile = preload("res://Assets/Terminal/Determination.ttf")
	const fontSize : int = 18
	const terminalFontColor : Color = Color8(242, 240, 228, 255)	
	const placeholderFontColor : Color = Color8(242, 240, 228, 100)

	super._init(texture, font, fontSize, terminalFontColor)
	super.setWindowText(TERMINAL_PATH)

	var reference : Rect2 = super.getSpriteRect()
	WindowUtils.configureWindowTextObj(_typingSpace, font, fontSize, reference, terminalFontColor)
	_originalTypingSpacePos = _typingSpace.position
	
	_typingSpace.connect("text_changed", _checkTypedChar)
	_typingSpace.connect("text_submitted", _enterCommand)

	super.addChild(_typingSpace)

	WindowUtils.configureWindowTextObj(_placeholder, font, fontSize, reference, placeholderFontColor, true)
	_placeholder.text = "help"
	_originalPlaceholderPos = _placeholder.position

	super.addChild(_placeholder)

	_OnEnterCommandYOffset = super.getEnterYOffset()


# PUBLIC METHODS

func setPlaceholderText(text : String):
	_placeholder.text = text


func adjustYPos(offset : float):
	if _textIsNotInTheEdge():
		_typingSpace.position.y += offset
		_placeholder.position.y += offset


func returnToOriginalPos():
	_typingSpace.position = _originalTypingSpacePos
	_placeholder.position = _originalPlaceholderPos


# PRIVATE METHODS

func _erasePlaceholder(index : int):
	if index < len(_placeholder.text):
		_erasedChars.append(_placeholder.text[index])
		_placeholder.text[index] = "_"


func _returnPlaceholderChar(index : int):
	if index < len(_placeholder.text):
		_placeholder.text[index] = _erasedChars[-1]
		_erasedChars.pop_back()


func _resetPlaceHolderText():
	for i in range(len(_erasedChars)):
		_placeholder.text[i] = _erasedChars[i]
	_erasedChars.clear()


func _resetTypingSpaceText():
	_lastTextLength = 0
	_typingSpace.clear()


func _textIsNotInTheEdge():
	return _typingSpace.position.y + _TYPING_SPACE_LIMIT_OFFSET < super.getSpriteHeight()


# EVENT LISTENER

func _input(event):
	if event is InputEventMouseButton and _isInsideWindow(to_local(event.position)) and _typingSpace:
		_typingSpace.grab_focus()
		_typingSpace.caret_column = len(_typingSpace.text)


# CALLABLES FOR SIGNALS

func _checkTypedChar(newText : String):
	var newTextLength = len(newText)

	if _lastTextLength > newTextLength:
		_returnPlaceholderChar(newTextLength)

	elif _lastTextLength < newTextLength:
		_erasePlaceholder(newTextLength - 1)

	_lastTextLength = newTextLength


func _enterCommand(newText : String):
	if _textIsNotInTheEdge():
		_typingSpace.position.y += _OnEnterCommandYOffset
		_placeholder.position.y += _OnEnterCommandYOffset

	_resetPlaceHolderText()
	_resetTypingSpaceText()

	_commandExecuter.executeCommand(newText, self)
