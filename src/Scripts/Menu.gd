extends Sprite2D

@onready var turnOff : PackedScene = load("res://Scenes/TurnOff.tscn")


func getFakeButton():
	return $Fake

func _on_off_button_up():
	get_tree().change_scene_to_packed(turnOff)
