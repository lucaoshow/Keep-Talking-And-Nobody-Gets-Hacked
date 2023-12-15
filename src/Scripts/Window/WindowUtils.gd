class_name WindowUtils

const _PIXELATE_TEXT_SCALE : Vector2 = Vector2(1.5, 1.5)
const _SIZE_OFFSET : int = 40
const _WINDOW_TEXT_POS_OFFSET : Vector2 = Vector2(16, 56)
const _WINDOW_TEXT_LINE_SPACING : int = 10
const _TYPING_SPACE_POS_OFFSET : Vector2 = Vector2(256, 40)
const _PLACEHOLDER_POS_OFFSET : Vector2 = Vector2(262, 56)

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
