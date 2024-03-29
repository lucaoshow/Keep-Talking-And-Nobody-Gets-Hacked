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
@onready var explosion : PackedScene = preload("res://Scenes/Explosion.tscn")
var _explosionCount : int = 0
var _originalPos : Vector2
const EXPLOSION_POSITIONS : Array[Vector2] = [Vector2(-328, -64), Vector2(192, -56), Vector2(32, 64), Vector2(-88, -136), Vector2(-50, 60)]

var _deleting : bool = false
var _helped : bool = false
var _scanned : bool = false
var _users : bool = false
var _removedWrong : bool = false
var _analysed : bool = false
var _canAct : bool = true
var _winCondition : bool = false
var _removedRight : int = 0
var _enteredDir : int = 0
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


func setOriginalPos(pos : Vector2):
	self._originalPos = pos

# PRIVATE METHODS


func _explode():
	for i in range(len(self.EXPLOSION_POSITIONS)):
		var e = self.explosion.instantiate()
		e.position = self.EXPLOSION_POSITIONS[i]
		e.connect("animation_finished", self.onExploded.bind(e))
		self._startNewTimer((i + 0.1) * 0.5, self._createExplosion.bind(e))


func _createExplosion(anim):
	self.add_child(anim)


func _canWrite():
	return !super.isWriting() and !self._deleting and self.deleteTimer.is_stopped()


func _write(text : String, erasable : bool = false):
	if (self._canWrite()):
		super.writeAnimatedText(text)
		if (erasable):
			self.deleteTimer.start()


func _startNewTimer(waitTime : float, timeoutCall : Callable):
	var timer : Timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = waitTime
	timer.connect("timeout", timeoutCall)
	self.add_child(timer)
	timer.start()


func _getTerminalFormat(text : String):
	return "X:\\>" + text


func _introduce():
	self._write(self._getTerminalFormat("echosec  init\n"))


func _delete():
	var text : String = super.getWindowText()
	var lastCharPos : int = len(text)-1
	if (text[lastCharPos] != ">"):
		super.setWindowText(text.erase(lastCharPos))
		return
	self._deleting = false


func _playerBackOneDir(msg : String):
	super.setWindowText(super.getWindowText() + " back-dir  -n  1  -u  Inteli\n" + msg + "\n" + self._getTerminalFormat(""))
	self._playerTerminal.togglePause()
	self._playerTerminal.forceCommand("cd..")
	self._playerTerminal.togglePause()


func canAct(condition : bool):
	return condition and self._canAct 

# EVENT LISTENERS

func onStartTimeout():
	self.start.emit()
	self._write('HAHAHAHA!  Espero que não se importe, mas estou só dando uma espiadinha nos seus arquivos.\nNada demais, sou só um hacker amigável explorando seu sistema!  Prazer!\nVou apenas adicionar uns "temperos especiais" nos seus arquivos. Eles vão pegar um\nresfriadinho ou dois. Na verdade três, mas nada sério!\n\nPra começar, que tal tirarmos algumas das suas permissões?\n' + self._getTerminalFormat("echosec  steal-permissions  -u  Inteli\n"))
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
	self._canAct = false
	self.global_position = Vector2(2000, 2000)
	self.visibility.emit()
	self._winCondition = true


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
		self._write("Ei, o que você tá fazendo aí? Pode parando com isso!\n" + self._getTerminalFormat(" generate-popups\n") + self._getTerminalFormat(""))
		self.popUps.emit()
		self._scanned = true


func onRemoveWrongFile():
	if (self.canAct(!self._removedWrong)):
		self._write("Hahaha!  Era isso que você queria apagar? Sério? Tente de novo, noob!", true)
		self._removedWrong = true


func onRemoveRightFile():
	if (self.canAct(self._removedRight == 0)):
		self._write("Ei!  Isso era arte digital!  Você acabou de deletar um dos meus vírus favoritos.\n" + self._getTerminalFormat(" shrink  -s  30  -u  Inteli\n") + 'Shrinking "Inteli" terminal...\n')
		self._startNewTimer(3, self.onShrinkingRequestTimeout)
	if (self.canAct(self._removedRight == 1)):
		self._write("Para com isso!  Assim você vai acabar com todos eles!\n" + self._getTerminalFormat(" generate-popups\n") + self._getTerminalFormat(""))
		self.popUps.emit()
	if (self._removedRight == 2 and self._winCondition):
		self.playerWin.emit()
	if (self.canAct(self._removedRight == 2)):
		self._write("NAOOOOOOOOOOOO!  VOCÊ ACABOU COM TODOS...\nPor favor, só não me tire da rede agora... Eu não tenho para onde ir!\n" + self._getTerminalFormat(""))
		self._winCondition = true
	self._removedRight += 1


func onOut():
	if (self._winCondition):
		self._explode()
		self._write("Maldito!!!  Eu vou voltar!!!  Pode esperar por mim!")
		self.playerWin.emit()
		return
	self._write("Ei, vamos conversar sobre isso!  Não precisa me desconectar. Sou um hacker muito\nlegal, prometo!  Vamos fazer um acordo, que tal? Eu até paro de infectar\nseus arquivos... por enquanto.\n")
	self._startNewTimer(15, self.onOutTimeout)


func onBack():
	super.setWindowText(self._getTerminalFormat(""))
	self._canAct = true
	self.position = self._originalPos
	self.visibility.emit()
	self._winCondition = false
	self._write("Ei, isso foi esperto!  Mas você acha que já acabou? Hahaha. Eu voltei!  :)", true)


func onAnalysis():
	if (self.canAct(!self._analysed)):
		self._write("Ei, tira o olho daí!\n" + self._getTerminalFormat(" generate-popups\n") + self._getTerminalFormat(""))
		self.popUps.emit()
		self._analysed = true


func onEnterDirectory():
	if (self.canAct(self._enteredDir == 0)):
		self._playerBackOneDir("Nem pense em entrar nesse diretório!")
	if (self.canAct(self._enteredDir == 1)):
		self._playerBackOneDir("Quantas vezes vou ter que te dizer?")
	if (self.canAct(self._enteredDir == 2)):
		self._playerBackOneDir("E se eu pedir por favor?")
	if (self.canAct(self._enteredDir == 3)):
		self._write("Entra então, eu desisto! Que insistente...", true)
	self._enteredDir += 1


func onExploded(anim):
	self._explosionCount += 1
	anim.queue_free()
	if (self._explosionCount == len(self.EXPLOSION_POSITIONS)):
		self.queue_free() 

