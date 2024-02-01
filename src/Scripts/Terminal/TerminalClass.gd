extends WindowDisplay
class_name Terminal


signal entered

const _TYPING_SPACE_LIMIT_OFFSET : float = 330
const _TYPING_SPACE_MAX_CHARS : int = 70

var TERMINAL_PATH : String = "C:\\>"
var _commandExecuter : Commands = Commands.new()
var _typingSpace : LineEdit = LineEdit.new()

var _OnEnterCommandYOffset : float
var _originalTypingSpacePos : Vector2


# CONSTRUCTOR

func _init(commandExecuter : Commands):
	self._commandExecuter = commandExecuter
	self.add_child(_commandExecuter)

	const texture : CompressedTexture2D = preload("res://Assets/Terminal/terminal.png")
	const font : FontFile = preload("res://Assets/Terminal/Determination.ttf")
	const fontSize : int = 15
	const terminalFontColor : Color = Color8(242, 240, 228, 255)

	super._init(texture, font, fontSize, terminalFontColor)

	var reference : Rect2 = super.getSpriteRect()
	WindowUtils.configureWindowTextObj(self._typingSpace, font, fontSize, reference, terminalFontColor)
	self._typingSpace.max_length = self._TYPING_SPACE_MAX_CHARS
	self._typingSpace.text = self.TERMINAL_PATH
	self._originalTypingSpacePos = self._typingSpace.position
	
	
	self._typingSpace.connect("text_changed", self._checkTypedChar)
	self._typingSpace.connect("text_submitted", self._enterCommand)
	self._typingSpace.connect("visibility_changed", self._onVisibilityChanged)

	super.addChild(self._typingSpace)

	super.setTaskbarText("Terminal")

	self._OnEnterCommandYOffset = super.getEnterYOffset()


func _ready():
	self.entered.emit()


# UPDATE PER FRAME

func _process(delta):
	super._process(delta)
	if super.isWriting():
		self._typingSpace.editable = false
		self._typingSpace.visible = false
	else:
		self._typingSpace.editable = true
		self._typingSpace.visible = true


# PUBLIC METHODS

func adjustYPos(offset : float):
	if self._textIsNotInTheEdge():
		self._typingSpace.position.y += offset


func returnToOriginalPos():
	self._typingSpace.position = self._originalTypingSpacePos


func goBackOneDir():
	var index : int = self.TERMINAL_PATH.rfind("\\")
	var charsToDelete : int = (len(self.TERMINAL_PATH)) - index
	self.TERMINAL_PATH = self.TERMINAL_PATH.erase(index, charsToDelete)
	if (self.TERMINAL_PATH[-1] == ":"):
		self.TERMINAL_PATH += "\\"
	self.TERMINAL_PATH += ">"
	self._resetTypingSpaceText()


func navigateToDir(dir : String):
	if (self.TERMINAL_PATH[-2] == "\\"):
		self.TERMINAL_PATH = self.TERMINAL_PATH.erase(len(self.TERMINAL_PATH) - 1)
	self.TERMINAL_PATH[-1] = "\\"
	self.TERMINAL_PATH += dir + ">"
	self._resetTypingSpaceText()


# PRIVATE METHODS

func _resetTerminalText():
	self._typingSpace.text = self.TERMINAL_PATH + self._typingSpace.text.substr(len(self.TERMINAL_PATH) - 1)
	self._typingSpace.caret_column = len(self._typingSpace.text)


func _resetTypingSpaceText():
	self._typingSpace.text = self.TERMINAL_PATH
	self._typingSpace.caret_column = len(self._typingSpace.text)


func _textIsNotInTheEdge():
	return self._typingSpace.position.y + self._TYPING_SPACE_LIMIT_OFFSET < super.getSpriteHeight()


func _grabFocus():
	self._typingSpace.grab_focus()
	self._typingSpace.caret_column = len(self._typingSpace.text)


# EVENT LISTENER

func _input(event):
	if event is InputEventMouseButton and super._isInsideWindow(to_local(event.position)) and self._typingSpace:
		self._grabFocus()


# CALLABLES FOR SIGNALS

func _checkTypedChar(_newText : String):
	if !_typingSpace.text.begins_with(self.TERMINAL_PATH):
		_resetTerminalText()
		return


func _enterCommand(newText : String):
	self.adjustYPos(self._OnEnterCommandYOffset)

	self._resetTypingSpaceText()
	
	var command : String = newText.substr(len(self.TERMINAL_PATH))

	self._commandExecuter.executeCommand(command, self)


func _onVisibilityChanged():
	if (self._typingSpace.visible == true):
		self._grabFocus()
