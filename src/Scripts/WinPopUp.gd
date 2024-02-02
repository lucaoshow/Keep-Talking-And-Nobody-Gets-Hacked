extends Sprite2D

@onready var turnOn : PackedScene = preload("res://Scenes/TurnOn.tscn")


func updatePoints(points : String):
	$Label.text += points


func _on_button_button_up():
	get_tree().change_scene_to_packed(turnOn)
