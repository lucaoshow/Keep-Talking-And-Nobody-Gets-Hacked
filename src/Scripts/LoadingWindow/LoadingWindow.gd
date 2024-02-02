extends Node2D


signal timeEnding
signal timeEnded

@onready var time : Label = $RemainingTime
@onready var counter : Timer = $Timer

const Y_POS : int = 625

var emitted : bool = false
var goingUp : bool = false
var seconds : int = 59
var minutes : int = 9

func startLoading():
	counter.start()
	goingUp = true


func goUp():
	if (position.y <= Y_POS):
		goingUp = false
		return

	position -= Vector2(0, 2)


func getPoints():
	return str($LoadingBar.max_value - $LoadingBar.value + 400)


func updateTime():
	seconds -= 1
	if (seconds < 0 and minutes > 0):
		seconds = 59 + (seconds + 1)
		minutes -= 1
	time.text = "Remaining time: " + str("%02d" % minutes) + ":" + str("%02d" % seconds)
	if (!emitted and minutes == 1):
		timeEnding.emit()
		emitted = true


func updateProgressBar():
	$LoadingBar.value += 1
	if ($LoadingBar.value == $LoadingBar.max_value):
		counter.stop()
		timeEnded.emit()


func _process(_delta):
	if (goingUp):
		goUp()


func reduceTime():
	seconds -= 10
	$LoadingBar.value += 10


func toggleTimer():
	if (counter.is_stopped()):
		counter.start()
		return
	counter.stop()


func _on_timer_timeout():
	updateTime()
	updateProgressBar()
