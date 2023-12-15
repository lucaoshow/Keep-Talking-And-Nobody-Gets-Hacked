extends WindowDisplay
class_name Terminal


const _TERMINAL_PATH : String = "C:\\WINDOWS\\System32>"

var _placeholder : Label = Label.new()
var _typingSpace : LineEdit = LineEdit.new()

var _erasedChars : Array[String]
var _OnEnterCommandYOffset : float
var _lastTextLength : int

func _init(widthScale : float, heightScale : float):
	const texture : CompressedTexture2D = preload("res://Assets/Terminal/terminal.png")
	const font : FontFile = preload("res://Assets/Terminal/CMD.ttf")
	const fontSize : int = 18
	const placeholderFontColor : Color = Color8(242, 240, 228, 100)
	const terminalFontColor : Color = Color8(242, 240, 228, 255)

	super._init(widthScale, heightScale, texture, font, fontSize, terminalFontColor)
	super.setWindowText(_TERMINAL_PATH)

	var reference : Rect2 = super.getSpriteRect()
	WindowUtils.configureWindowTextObj(_typingSpace, font, fontSize, reference, terminalFontColor)

	_typingSpace.connect("text_changed", _checkTypedChar)
	_typingSpace.connect("text_submitted", _enterCommand)

	super.addChild(_typingSpace)

	WindowUtils.configureWindowTextObj(_placeholder, font, fontSize, reference, placeholderFontColor, true)
	_placeholder.text = "clear"

	super.addChild(_placeholder)

	_OnEnterCommandYOffset = super.getEnterYOffset()


# PUBLIC METHODS

func setPlaceholderText(text : String):
	_placeholder.text = text


# PRIVATE METHODS

func _erasePlaceholder(index : int):
	if index < len(_placeholder.text):
		_erasedChars.append(_placeholder.text[index])
		_placeholder.text[index] = "_"


func _returnPlaceholderChar(index : int):
	if index < len(_placeholder.text):
		_placeholder.text[index] = _erasedChars[-1]
		_erasedChars.pop_back()


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
	var windowText = super.getWindowText()

	if super.textIsBiggerThanWindow():
		var charsToDelete : int = windowText.find("\n") + 1
		super.setWindowText(windowText.erase(0, charsToDelete))

	else:
		_typingSpace.position.y += _OnEnterCommandYOffset
		_placeholder.position.y += _OnEnterCommandYOffset

	super.setWindowText(super.getWindowText() + newText + "\n" + _TERMINAL_PATH)
	_placeholder.text = "clear" # remove this line in order to stop setting "clear" as the suggested command
	_erasedChars.clear()
	_lastTextLength = 0
	_typingSpace.clear()
