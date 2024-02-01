extends WindowDisplay

class_name Hacker

signal entered
signal start

@onready var startTimer : Timer = Timer.new()
@onready var deleteTimer : Timer =  Timer.new()

var _deleting : bool = false
var _terminalCount : int = 0
var _playerTerminal : Terminal


# CONSTRUCTOR

func _init():
	const texture : CompressedTexture2D = preload("res://Assets/Terminal/terminal.png")
	const font : FontFile = preload("res://Assets/Terminal/Determination.ttf")
	const fontSize : int = 15
	const terminalFontColor : Color = Color.GREEN

	super._init(texture, font, fontSize, terminalFontColor)

	super.setTaskbarText("EchoSec")


func _ready():
	self.entered.emit()
	super.freeCloseButton()
	self.startTimer.wait_time = 2
	self.deleteTimer.wait_time = 4
	self.startTimer.one_shot = true
	self.deleteTimer.one_shot = true
	self.startTimer.connect("timeout", self.onStartTimeout)
	self.deleteTimer.connect("timeout", self.onDeleteTimeout)
	self.add_child(self.startTimer)
	self.add_child(self.deleteTimer)
	self.startTimer.start()
	self._introduce()


# UPDATE PER FRAME

func _process(delta):
	super._process(delta)
	if (self._deleting):
		self._delete()


# PUBLIC METHODS

func setPlayerTerminal(playerTerminal : Terminal):
	self._playerTerminal = playerTerminal


# PRIVATE METHODS


func _canWrite():
	return !super.isWriting() and !self._deleting and self.deleteTimer.is_stopped()


func _write(text : String, erasable : bool = false):
	if (self._canWrite()):
		super.writeAnimatedText(text)
		if (erasable):
			self.deleteTimer.start()


func _startNewTimer(waitTime : int, timeoutCall : Callable):
	var timer : Timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = waitTime
	timer.connect("timeout", timeoutCall)
	self.add_child(timer)
	timer.start()


func _getTerminalFormat(text : String):
	return "X:\\>" + text


func _introduce():
	self._write(self._getTerminalFormat("echosec init\n"))


func _delete():
	var text : String = super.getWindowText()
	var lastCharPos : int = len(text)-1
	if (text[lastCharPos] != ">"):
		super.setWindowText(text.erase(lastCharPos))
		return
	self._deleting = false


# EVENT LISTENERS

func onStartTimeout():
	self.start.emit()
	self._write('HAHAHAHA! Espero que não se importe, mas estou só dando uma espiadinha nos seus arquivos.\nNada demais, só um hacker amigável aqui, explorando seu sistema!  Prazer!\nVou apenas adicionar uns "temperos especiais" nos seus arquivos. Eles vão pegar um\nresfriadinho ou dois. Na verdade três, mas nada sério!\n\nPra começar, que tal tirarmos algumas das suas permissões?\n' + self._getTerminalFormat("echosec steal-permissions -u Inteli\n"))
	self._startNewTimer(7, self.onStealPermissionsTimeout)


func onDeleteTimeout():
	self._deleting = true


func onStealPermissionsTimeout():
	self._write("User permissions successfully updated.\n" + self._getTerminalFormat(""))


func onPlayerOpenTerminal():
	if (self._terminalCount == 0):
		self._write("Olha só!  Parece que alguém sabe abrir o terminal!  Não que vá mudar alguma coisa...", true)
	
	if (self._terminalCount == 3):
		self._write("Entendo o desespero, mas você realmente precisa de tantos assim?", true)

	self._terminalCount += 1


func onTimeEnding():
	self._write("Tic-tac, tic-tac!  O relógio está correndo, hein! HAHAHA", true)


func onScanningNetwork():
	return


func onRemovingFromNetwork():
	return


func onRightDirectory():
	return


func onRemoveRightFile():
	return


func onPlayerWin():
	return
