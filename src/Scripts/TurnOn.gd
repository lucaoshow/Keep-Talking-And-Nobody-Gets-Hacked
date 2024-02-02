extends Node2D

@onready var main : PackedScene = preload("res://Scenes/Main.tscn")


func _on_login_button_button_up():
	$Login.hide()
	$Transition.start()


func _on_transition_timeout():
	get_tree().change_scene_to_packed(main)
