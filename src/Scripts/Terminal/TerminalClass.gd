extends WindowDisplay
class_name Terminal


const TERMINAL_PATH : String = "C:\\WINDOWS\\System32>"
const _TYPING_SPACE_LIMIT_OFFSET : float = 330
const _TYPING_SPACE_MAX_CHARS : int = 61

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
	super.setWindowText(self.TERMINAL_PATH)

	var reference : Rect2 = super.getSpriteRect()
	WindowUtils.configureWindowTextObj(self._typingSpace, font, fontSize, reference, terminalFontColor)
	self._typingSpace.max_length = self._TYPING_SPACE_MAX_CHARS
	self._originalTypingSpacePos = self._typingSpace.position
	
	
	self._typingSpace.connect("text_changed", self._checkTypedChar)
	self._typingSpace.connect("text_submitted", self._enterCommand)

	super.addChild(self._typingSpace)

	WindowUtils.configureWindowTextObj(self._placeholder, font, fontSize, reference, placeholderFontColor, true)
	self._placeholder.text = "help"
	self._originalPlaceholderPos = self._placeholder.position

	super.addChild(self._placeholder)

	super.setTaskbarText("Terminal")

	self._OnEnterCommandYOffset = super.getEnterYOffset()


# UPDATE PER FRAME
func _process(delta):
	super._process(delta)
	if super.isWriting():
		self._typingSpace.editable = false
		self.setPlaceholderText("")
	else:
		self._typingSpace.editable = true


# PUBLIC METHODS

func setPlaceholderText(text : String):
	self._placeholder.text = text


func adjustYPos(offset : float):
	if self._textIsNotInTheEdge():
		self._typingSpace.position.y += offset
		self._placeholder.position.y += offset


func returnToOriginalPos():
	self._typingSpace.position = self._originalTypingSpacePos
	self._placeholder.position = self._originalPlaceholderPos


# PRIVATE METHODS

func _erasePlaceholder(index : int):
	if index < len(self._placeholder.text):
		self._erasedChars.append(self._placeholder.text[index])
		self._placeholder.text[index] = "_"


func _returnPlaceholderChar(index : int):
	if index < len(self._placeholder.text):
		self._placeholder.text[index] = self._erasedChars[-1]
		self._erasedChars.pop_back()


func _resetPlaceHolderText():
	for i in range(len(self._erasedChars)):
		self._placeholder.text[i] = self._erasedChars[i]
	self._erasedChars.clear()


func _resetTypingSpaceText():
	self._lastTextLength = 0
	self._typingSpace.clear()


func _textIsNotInTheEdge():
	return self._typingSpace.position.y + self._TYPING_SPACE_LIMIT_OFFSET < super.getSpriteHeight()


# EVENT LISTENER

func _input(event):
	if event is InputEventMouseButton and super._isInsideWindow(to_local(event.position)) and self._typingSpace:
		self._typingSpace.grab_focus()
		self._typingSpace.caret_column = len(self._typingSpace.text)


# CALLABLES FOR SIGNALS

func _checkTypedChar(newText : String):
	var newTextLength = len(newText)

	if self._lastTextLength > newTextLength:
		self._returnPlaceholderChar(newTextLength)

	elif self._lastTextLength < newTextLength:
		self._erasePlaceholder(newTextLength - 1)

	self._lastTextLength = newTextLength


func _enterCommand(newText : String):
	if self._textIsNotInTheEdge():
		self._typingSpace.position.y += self._OnEnterCommandYOffset
		self._placeholder.position.y += self._OnEnterCommandYOffset

	self._resetPlaceHolderText()
	self._resetTypingSpaceText()

	self._commandExecuter.executeCommand(newText, self)
