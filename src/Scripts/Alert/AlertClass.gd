extends WindowDisplay

class_name Alert


# CONSTRUCTOR

func _init():
	var texture : CompressedTexture2D = preload("res://Assets/Alert/alert.png")
	# irrelevant
	var font : FontFile = preload("res://Assets/Terminal/Determination.ttf") 
	var fontSize : int = 12
	var fontColor : Color = Color("white")

	super._init(texture, font, fontSize, fontColor)
	super.setTaskbarText("Alert")
