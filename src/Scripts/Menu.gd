extends Sprite2D

@onready var turnOnScene : PackedScene = preload("res://Scenes/TurnOn.tscn")


func getFakeButton():
	return $Fake

func _on_off_button_up():
	get_tree().change_scene_to_packed(turnOnScene)
