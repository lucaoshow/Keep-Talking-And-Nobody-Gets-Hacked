extends Node2D
class_name WindowDisplay

enum States {IDLE = 1, RESIZING, MOVING}
var _currentState : States = States.IDLE

var _windowSprite : Sprite2D = Sprite2D.new()

var _targetScaleX : float
var _targetScaleY : float
var _t : float
var _targetPosition : Vector2
var _elapsedTime : float


# change the standard sprite later
func _init(width : float, height : float, windowTexture : CompressedTexture2D = preload("res://Assets/Window/test_sprite.svg")):
	_windowSprite.scale.x = width
	_windowSprite.scale.y = height
	_windowSprite.texture = windowTexture
	add_child(_windowSprite)


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
	_elapsedTime += delta * _t
	_windowSprite.scale.x = lerpf(_windowSprite.scale.x, _targetScaleX, _t * delta)
	_windowSprite.scale.y = lerpf(_windowSprite.scale.y, _targetScaleY, _t * delta)
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
