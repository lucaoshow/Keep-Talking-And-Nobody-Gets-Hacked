extends Node2D

@onready var turnOn : PackedScene = preload("res://Scenes/TurnOn.tscn")


func _on_retry_button_up():
	get_tree().change_scene_to_packed(turnOn)
