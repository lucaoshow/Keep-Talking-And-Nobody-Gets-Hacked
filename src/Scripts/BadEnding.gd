extends Node2D

@onready var main : PackedScene = preload("res://Scenes/Main.tscn")


func _on_retry_button_up():
	get_tree().change_scene_to_packed(main)
