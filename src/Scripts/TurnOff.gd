extends Node2D

var transitioning : bool = false
@onready var turnOn : PackedScene = load("res://Scenes/TurnOn.tscn")

func _ready():
	$ShowDefeat.start()


func _on_show_defeat_timeout():
	$Logoff.hide()
	transitioning = true


func _process(delta):
	if (transitioning and $Black.color.a > 0):
		$Black.color.a -= delta
	if (transitioning and $Black.color.a <= 0):
		transitioning = false
		$Black.queue_free()


func _on_retry_button_up():
	get_tree().change_scene_to_packed(turnOn)
