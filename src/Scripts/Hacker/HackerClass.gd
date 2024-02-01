extends WindowDisplay

class_name Hacker

signal entered
signal start
signal popUps
signal visibility
signal playerWin
signal buttons

@onready var startTimer : Timer = Timer.new()
@onready var deleteTimer : Timer =  Timer.new()

var _deleting : bool = false
var _helped : bool = false
var _scanned : bool = false
var _users : bool = false
var _removedWrong : bool = false
var _analysed : bool = false
var _canAct : bool = true
var _removedRight : int = 0
var _terminalCount : int = 0
var _playerTerminal : Terminal


# CONSTRUCTOR

func _init():
	const texture : CompressedTexture2D = preload("res://Assets/Hacker/hacker_terminal.png")
	const font : FontFile = preload("res://Assets/Terminal/Determination.ttf")
	const fontSize : int = 13
	const terminalFontColor : Color = Color.GREEN

	super._init(texture, font, fontSize, terminalFontColor)
	super.setWindowTextLimitOffset(160)

	super.setTaskbarText("EchoSec")


func _ready():
	self.entered.emit()
	super.freeCloseButton()
	self.startTimer.wait_time = 2
	self.deleteTimer.wait_time = 6
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


func canAct(condition : bool):
	return condition and self._canAct 

# EVENT LISTENERS

func onStartTimeout():
	self.start.emit()
	self._write('HAHAHAHA! Espero que não se importe, mas estou só dando uma espiadinha nos seus arquivos.\nNada demais, sou só um hacker amigável explorando seu sistema!  Prazer!\nVou apenas adicionar uns "temperos especiais" nos seus arquivos. Eles vão pegar um\nresfriadinho ou dois. Na verdade três, mas nada sério!\n\nPra começar, que tal tirarmos algumas das suas permissões?\n' + self._getTerminalFormat("echosec steal-permissions -u Inteli\n"))
	self._startNewTimer(7, self.onStealPermissionsTimeout)


func onDeleteTimeout():
	self._deleting = true


func onStealPermissionsTimeout():
	self._write("User permissions successfully updated.\n" + self._getTerminalFormat(""))
	self.buttons.emit()


func onShrinkingRequestTimeout():
	self._playerTerminal.resize(0.3, 0.3, 1)
	self._startNewTimer(30, self.onShrinkTimeout)
	self._write(self._getTerminalFormat(""))


func onShrinkTimeout():
	self._playerTerminal.returnToOriginalSize()


func onOutTimeout():
	self.visible = false
	self._canAct = false
	self.visibility.emit()


func onPlayerOpenTerminal():
	if (self.canAct(self._terminalCount == 0)):
		self._write("Olha só!  Parece que alguém sabe abrir o terminal!  Não que vá mudar alguma coisa...", true)
	
	if (self.canAct(self._terminalCount == 3)):
		self._write("Entendo o desespero, mas você realmente precisa de tantos assim?", true)

	self._terminalCount += 1


func onTimeEnding():
	if (self.canAct(true)):
		self._write("Tic-tac, tic-tac!  O relógio está correndo, hein! HAHAHA", true)


func onHelp():
	if (self.canAct(!self._helped)):
		self._write("Precisa de uma ajudinha aí? Que patético...", true)
		self._helped = true


func onUsers():
	if (self.canAct(!self._users)):
		self._write("Me achou, né? Não se preocupe, já já eu saio daqui, rs", true)
		self._users = true


func onScanningNetwork():
	if (self.canAct(!self._scanned)):
		self._write("Ei, o que você tá fazendo aí? Pode parando com isso!\n" + self._getTerminalFormat("generate-popups\n") + self._getTerminalFormat(""))
		self.popUps.emit()
		self._scanned = true


func onRemoveWrongFile():
	if (self.canAct(!self._removedWrong)):
		self._write("Hahaha! Era isso que você queria apagar? Sério? Tente de novo, noob!", true)
		self._removedWrong = true


func onRemoveRightFile():
	if (self.canAct(self._removedRight == 0)):
		self._write("Ei! Isso era arte digital! Você acabou de deletar um dos meus vírus favoritos.\n" + self._getTerminalFormat("shrink -s 30 -u Inteli\n") + 'Shrinking "Inteli" terminal...\n')
		self._startNewTimer(3, self.onShrinkingRequestTimeout)
	if (self.canAct(self._removedRight == 1)):
		self._write("Para com isso! Assim você vai acabar com todos eles!", true)
	if (self.canAct(self._removedRight == 2)):
		self._write("NAOOOOOOOOOOOO! MEUS BEBÊS...", false)
		self.playerWin.emit()
		self._startNewTimer(4, self.onPlayerWin)
	self._removedRight += 1


func onOut():
	self._write("Ei, vamos conversar sobre isso! Não precisa me desconectar. Sou um hacker\nmuito legal, prometo! Vamos fazer um acordo, que tal? Eu até paro\nde infectar seus arquivos... por enquanto.")
	self._startNewTimer(12, self.onOutTimeout)


func onBack():
	super.setWindowText(self._getTerminalFormat(""))
	self.visible = true
	self._canAct = true
	self.visibility.emit()
	self._write("Ei, isso foi esperto! Mas você acha que já acabou? Hahaha. Eu voltei!  :)", true)


func onAnalysis():
	if (self.canAct(!self._analysed)):
		self._write("Ei, tira o olho daí!\n" + self._getTerminalFormat("generate-popups\n") + self._getTerminalFormat(""))
		self.popUps.emit()
		self._analysed = true


func onPlayerWin():
	self.queue_free()
