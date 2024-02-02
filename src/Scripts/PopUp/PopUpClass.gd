extends WindowDisplay

class_name PopUp


# CONSTRUCTOR

func _init():
	const assetsPath : String = "res://Assets/PopUp/"
	var popUpTextureDir : String = WindowUtils.getRandomPopUpTextureDirectory()
	var files : Array = Array(DirAccess.get_files_at(assetsPath + popUpTextureDir))

	#files = files.filter(func(x : String): return false if x[-1] == "t" else true) # RUN LOCAL
	files = files.map(func(x : String): return x.substr(0, x.rfind("."))) # DEPLOY

	var texture : CompressedTexture2D = load(assetsPath + popUpTextureDir + "/" + files[0])
	# irrelevant (no labels in pop-ups)
	var font : FontFile = preload("res://Assets/Terminal/Determination.ttf") 
	var fontSize : int = 12
	var fontColor : Color = Color("white")

	super._init(texture, font, fontSize, fontColor)
	super.setTaskbarText(WindowUtils.getRandomPopUpTitle())

	if (files.size() > 1):
		var textures : Array[CompressedTexture2D] = [texture]
		for i in range(1, files.size()):
			textures.append(load(assetsPath + popUpTextureDir + "/" + files[i]))

		super.configureAnimation(textures)
