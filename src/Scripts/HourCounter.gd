extends Label

@onready var time : String = Time.get_time_string_from_system()
@onready var counter : Timer = $Counter
var currentHour : int
var currentMinute : int

func _ready():
	var timeElements = time.split(":")
	counter.wait_time = 60 - int(timeElements[2])
	self.text = timeElements[0] + ":" + timeElements[1] # hours:minutes
	currentHour = int(timeElements[0])
	currentMinute = int(timeElements[1])
	counter.start()


func updateText():
	currentMinute += 1
	if currentMinute == 60:
		currentMinute = 0
		currentHour += 1
	if currentHour > 23:
		currentHour = 0
	
	self.text = str("%02d" % currentHour) + ":" + str("%02d" % currentMinute)


func _on_counter_timeout():
	counter.wait_time = 60
	updateText()
	counter.start()
