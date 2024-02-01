extends Node2D

@onready var time : Label = $RemainingTime
@onready var counter : Timer = $Timer

const Y_POS : int = 578
var goingUp : bool = false
var seconds : int = 59
var minutes : int = 6

func startLoading():
	counter.start()
	goingUp = true


func goUp():
	if (position.y <= Y_POS):
		goingUp = false
		return

	position -= Vector2(0, 2)


func updateTime():
	seconds -= 1
	if (seconds < 0 and minutes > 0):
		seconds = 59
		minutes -= 1
	time.text = "Remaining time: " + str("%02d" % minutes) + ":" + str("%02d" % seconds)


func updateProgressBar():
	$LoadingBar.value += 1
	if ($LoadingBar.value == $LoadingBar.max_value):
		counter.stop()
		lose()


func lose():
	pass


func _process(_delta):
	if (goingUp):
		goUp()


func _on_timer_timeout():
	updateTime()
	updateProgressBar()
