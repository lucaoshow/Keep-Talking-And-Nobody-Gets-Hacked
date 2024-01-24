class_name WindowUtils

const _PIXELATE_TEXT_SCALE : Vector2 = Vector2(1.5, 1.5)
const _SIZE_OFFSET : int = 40
const _WINDOW_TEXT_POS_OFFSET : Vector2 = Vector2(16, 56)
const _WINDOW_TEXT_LINE_SPACING : int = 10
const _TYPING_SPACE_POS_OFFSET : Vector2 = Vector2(238, 40)
const _PLACEHOLDER_POS_OFFSET : Vector2 = Vector2(245, 55)

const _IMAGE_POSITION : Vector2 = Vector2(0, 18)
const _IMAGE_TARGET_X_SIZE : int = 27
const _IMAGE_TARGET_Y_SIZE : int = 18
const _TEXT_POSITION : Vector2 = Vector2(25, 7)
const _PIXELATE_LABEL_FILTER_SCALE : Vector2 = Vector2(1.32, 1.32)
const _BORDER_SIZE : Vector2 = Vector2(145, 32)
const _BORDER_POSITION : Vector2 = Vector2(-25, 2)

const _BUTTON_SIZE : Vector2 = Vector2(29,29)
const _BUTTON_X_OFFSET : int = -30
const _BUTTON_Y_OFFSET : int = 7

const TASKBAR_WINDOW_BUTTON_X_OFFSET : int = 20
const TASKBAR_WINDOW_BUTTON_Y_POS : int = 2

const POPUPS_TITLES : Array[String] = ["GRÁTIS", "Eiii Psiu", "ATENÇÃO", "CLIQUE", "URGENTE", "GANHOU", "PRÊMIO", "ANÚNCIO"]


static func configureWindowTextObj(obj : Object, font : FontFile, fontSize : int, reference : Rect2,
									fontColor : Color, usePlaceholderOffset : bool = false):

	obj.scale = _PIXELATE_TEXT_SCALE
	obj.size = Vector2(reference.size.x - _SIZE_OFFSET, _SIZE_OFFSET)
	obj.position = reference.position + _WINDOW_TEXT_POS_OFFSET

	obj.set("theme_override_constants/line_spacing", _WINDOW_TEXT_LINE_SPACING)
	obj.set("theme_override_fonts/font", font)
	obj.set("theme_override_colors/font_color", fontColor)
	obj.set("theme_override_font_sizes/font_size", fontSize)
	
	if obj.is_class("LineEdit"):
		obj.position = reference.position + _TYPING_SPACE_POS_OFFSET
		obj.flat = true
		obj.set("theme_override_styles/focus", StyleBoxEmpty.new())

	elif usePlaceholderOffset:
		obj.position = reference.position + _PLACEHOLDER_POS_OFFSET

static func configureTaskbarWindowObj(obj : TaskbarWindow, img : CompressedTexture2D, text : String):
	var styleBox = StyleBoxTexture.new()
	styleBox.texture = preload("res://Assets/Taskbar/TaskbarWindow/background.png")

	var border : Panel = Panel.new()
	border.set("theme_override_styles/panel", styleBox)
	border.size = _BORDER_SIZE
	border.position = _BORDER_POSITION

	var image : Sprite2D = Sprite2D.new()
	image.texture = img
	image.position = _IMAGE_POSITION
	
	var scalingRef : Vector2 = image.get_rect().size 
	image.scale = Vector2(_IMAGE_TARGET_X_SIZE / scalingRef.x, _IMAGE_TARGET_Y_SIZE / scalingRef.y)

	var label : Label = Label.new()
	label.scale = _PIXELATE_LABEL_FILTER_SCALE
	var font : FontFile = preload("res://Assets/Taskbar/TaskbarWindow/SEGUISB.TTF")
	var fontSize : int = 12
	label.text = text
	label.position = _TEXT_POSITION
	label.set("theme_override_fonts/font", font)
	label.set("theme_override_font_sizes/font_size", fontSize)

	obj.add_child(border)
	obj.add_child(image)
	obj.add_child(label)


static func generateWindowCloseButton(rectSize : Vector2):
	var button : Button = Button.new()
	button.size = _BUTTON_SIZE
	button.flat = true
	button.position = Vector2(rectSize.x / 2 + _BUTTON_X_OFFSET , rectSize.y / -2 + _BUTTON_Y_OFFSET)
	button.set("theme_override_styles/focus", StyleBoxEmpty.new())

	return button


static func generateTaskbarWindowCloseButton():
	var button : TextureButton = TextureButton.new()
	button.scale = _PIXELATE_LABEL_FILTER_SCALE
	button.texture_normal = preload("res://Assets/Taskbar/TaskbarWindow/close.png")
	button.texture_hover = preload("res://Assets/Taskbar/TaskbarWindow/close_hover.png")
	button.position = Vector2(_BORDER_SIZE.x / 2 + TASKBAR_WINDOW_BUTTON_X_OFFSET, TASKBAR_WINDOW_BUTTON_Y_POS)
	return button


static func getRandomPopUpTextureDirectory():
	var files : PackedStringArray = DirAccess.get_directories_at("res://Assets/PopUp")
	var randomIndex : int = randi_range(0, files.size() - 1)

	return files[randomIndex]


static func getRandomPopUpTitle():
	return POPUPS_TITLES[randi_range(0, POPUPS_TITLES.size() - 1)]



static func getConfiguredAnimatedSprite():
	var animatedSprite : AnimatedSprite2D = AnimatedSprite2D.new()
	animatedSprite.position = Vector2.ZERO
	animatedSprite.sprite_frames = SpriteFrames.new()
	animatedSprite.sprite_frames.set_animation_loop("default", true)
	animatedSprite.sprite_frames.set_animation_speed("default", 5.0)
	animatedSprite.set_autoplay("default")
	
	return animatedSprite
