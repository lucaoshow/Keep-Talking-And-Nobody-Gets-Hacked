extends Node2D
class_name WindowDisplay

enum States {IDLE = 1, RESIZING, MOVING}
var _currentState : States = States.IDLE

var _windowSprite : Sprite2D = Sprite2D.new()
var _typingSpace : LineEdit = LineEdit.new()

const _terminalPath : String = "C:\\WINDOWS\\System32\\"

var _targetScaleX : float
var _targetScaleY : float
var _t : float
var _targetPosition : Vector2
var _elapsedTime : float


# change the standard sprite later
func _init(widthScale : float, heightScale : float, typeable : bool = true, windowTexture : CompressedTexture2D = preload("res://Assets/Terminal/terminal.png")):
	_windowSprite.scale.x = widthScale
	_windowSprite.scale.y = heightScale
	_windowSprite.texture = windowTexture
	add_child(_windowSprite)
	if typeable:
		var font : FontFile = preload("res://Assets/Terminal/CMD.ttf")
		var reference : Rect2 = _windowSprite.get_rect()
		_typingSpace.scale = Vector2(1.5,1.5)
		_typingSpace.size = Vector2(reference.size.x - 40, 40) # magical numbers
		_typingSpace.position = reference.position + Vector2(10, 40) # magical numbers
		_typingSpace.flat = true
		_typingSpace.set("theme_override_styles/focus", StyleBoxEmpty.new())
		_typingSpace.set("theme_override_fonts/font", font)
		_typingSpace.set("theme_override_font_sizes/font_size", 18)
		_typingSpace.text = _terminalPath
		_typingSpace.connect("text_changed", _blockterminalPathErasing)
		_typingSpace.connect("text_submitted", _enterCommand)
		_windowSprite.add_child(_typingSpace)
	else:
		_typingSpace.free()


func resize(widthPercentage : float, heightPercentage : float, t : float):
	_targetScaleX = _windowSprite.scale.x * widthPercentage
	_targetScaleY = _windowSprite.scale.y * heightPercentage
	_t = t
	_currentState = States.RESIZING


func moveTo(pos : Vector2, t : float):
	_targetPosition = pos
	_currentState = States.MOVING


func _checkActionFinished():
	if _elapsedTime >= _t:
		_currentState = States.IDLE
		_elapsedTime = 0


func _scale(delta : float):
	var tOverTime = _t * delta
	_elapsedTime += tOverTime
	_windowSprite.scale.x = lerpf(_windowSprite.scale.x, _targetScaleX, tOverTime)
	_windowSprite.scale.y = lerpf(_windowSprite.scale.y, _targetScaleY, tOverTime)
	_checkActionFinished()


func _reposition(delta : float):
	_elapsedTime += delta * _t
	position = position.lerp(_targetPosition, _t * delta)
	_checkActionFinished()


func _process(delta):
	if _currentState == States.RESIZING:
		_scale(delta)

	if _currentState == States.MOVING:
		_reposition(delta)


func _blockterminalPathErasing(newText : String):
	if len(_typingSpace.text) <= len(_terminalPath):
		_typingSpace.text = _terminalPath
		_typingSpace.caret_column = len(_terminalPath)


func _enterCommand(newText : String):
	_typingSpace.text += "\n" + _terminalPath
