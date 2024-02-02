extends Node2D

const HACKER_POS : Vector2 =  Vector2(1023, 153)
const PLAYER_POS : Vector2 = Vector2(416, 530)
var windows : Array[WindowDisplay]
var commandExecuters : Array[Commands]

@onready var taskbar : Taskbar = $Taskbar
@onready var loadingWindow = $LoadingWindow
@onready var hacker : Hacker = Hacker.new()
@onready var badEndingScene : PackedScene = preload("res://Scenes/BadEnding.tscn")
@onready var loseScene : PackedScene = preload("res://Scenes/TurnOff.tscn")


func _ready():
	$CMD.disabled = true
	$RecycleBin.disabled = true

func win():
	loadingWindow.queue_free()
	commandExecuters.map(func(x : Commands): x.cancelHackerBackTimer())


func lose():
	get_tree().change_scene_to_packed(loseScene)


func badEnding():
	get_tree().change_scene_to_packed(badEndingScene)


func hackerEntered():
	taskbar.disableCloseButton(hacker)
	

func activateButtons():
	$CMD.disabled = false
	$RecycleBin.disabled = false


func toggleHackerWindow():
	loadingWindow.toggleTimer()
	taskbar.toggleWindow(hacker)


func startLoadingWindow():
	loadingWindow.startLoading()
	loadingWindow.timeEnding.connect(hacker.onTimeEnding)
	loadingWindow.timeEnded.connect(self.lose)


func generatePopUps():
	for i in range(10):
		var popUp : PopUp = PopUp.new()
		popUp.position = Vector2(PLAYER_POS.x + i * 1.4, PLAYER_POS.y + i)
		windows.append(popUp)
		add_child(popUp)


func terminalOpened():
	hacker.onPlayerOpenTerminal()


func _on_start_timeout():
	hacker.entered.connect(hackerEntered)
	hacker.start.connect(startLoadingWindow)
	hacker.popUps.connect(generatePopUps)
	hacker.visibility.connect(toggleHackerWindow)
	hacker.playerWin.connect(win)
	hacker.buttons.connect(activateButtons)
	hacker.position = HACKER_POS
	windows.append(hacker)
	add_child(hacker)


func showNotAllowed():
	return #TODO: show not allowed pop-up


func isWindowDisplay(node : Node):
	return node is WindowDisplay

func isTaskbarWindow(node : Node):
	return node is TaskbarWindow


func freeCorrespondentWindow(id : int):
	for w in windows:
		if w.get_instance_id() == id:
			windows.erase(w)
			w.queue_free()


func _on_child_entered_tree(node):
	if isWindowDisplay(node):
		taskbar.onAddNewWindow(node)


func _on_child_exiting_tree(node):
	if isWindowDisplay(node):
		windows.erase(node)
		taskbar.onRemoveWindow(node.get_instance_id())


func _on_taskbar_child_exiting_tree(node):
	if isTaskbarWindow(node):
		freeCorrespondentWindow(node.id)


func _on_fake_button_up():
	showNotAllowed()


func _on_recycle_bin_button_up():
	if ($ButtonPress.is_stopped()):
		$ButtonPress.start()
		return
	$ButtonPress.stop()
	showNotAllowed()


func _on_menu_button_button_up():
	$Menu.visible = !$Menu.visible


func _on_cmd_button_up():
	if ($ButtonPress.is_stopped()):
		$ButtonPress.start()
		return
	$ButtonPress.stop()
	var commandExecuter = Commands.new()
	commandExecuter.help.connect(hacker.onHelp)
	commandExecuter.users.connect(hacker.onUsers)
	commandExecuter.scan.connect(hacker.onScanningNetwork)
	commandExecuter.analyseFile.connect(hacker.onAnalysis)
	commandExecuter.removedWrongFile.connect(hacker.onRemoveWrongFile)
	commandExecuter.removedRightFile.connect(hacker.onRemoveRightFile)
	commandExecuter.removedCriticalFile.connect(self.badEnding)
	commandExecuter.hackerOut.connect(hacker.onOut)
	commandExecuter.hackerBack.connect(hacker.onBack)
	commandExecuter.error.connect(loadingWindow.reduceTime)
	commandExecuter.enterDirectory.connect(hacker.onEnterDirectory)
	var terminal : Terminal = Terminal.new(commandExecuter)
	terminal.entered.connect(terminalOpened)
	terminal.position = PLAYER_POS
	windows.append(terminal)
	add_child(terminal)
	hacker.setPlayerTerminal(terminal)
	commandExecuters.append(commandExecuter)


func _on_off_button_up():
	get_tree().change_scene_to_packed(badEndingScene)


func _on_lol_button_up():
	if ($ButtonPress.is_stopped()):
		$ButtonPress.start()
		return
	$ButtonPress.stop()
	showNotAllowed()
