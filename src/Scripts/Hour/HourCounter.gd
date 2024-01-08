extends Label

@onready var time : String = Time.get_time_string_from_system()
@onready var counter : Timer = $Counter
var currentHour : int
var currentMinute : int

func _ready():
	var timeElements = self.time.split(":")
	self.counter.wait_time = 60 - int(timeElements[2])
	self.text = timeElements[0] + ":" + timeElements[1] # Format = hours:minutes => hh:mm
	self.currentHour = int(timeElements[0])
	self.currentMinute = int(timeElements[1])
	self.counter.start()


func updateText():
	self.currentMinute += 1
	if self.currentMinute == 60:
		self.currentMinute = 0
		self.currentHour += 1

	if self.currentHour > 23:
		self.currentHour = 0

	self.text = str("%02d" % self.currentHour) + ":" + str("%02d" % self.currentMinute)


func _on_counter_timeout():
	self.counter.wait_time = 60
	self.updateText()
	self.counter.start()
