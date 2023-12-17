@tool
class_name MovementLerp
extends XRToolsMovementProvider

# MovementLerp is a custom XR Tools movement provider
# it provides teleportation with rapid transition via linear interpolation

enum Controller { LEFT, RIGHT }

@export var order: int = 25 # movement provider priority (lowest runs first)
@export var controller: Controller = Controller.RIGHT
@export var lerp_button: String = "ax_button"
@export var lerp_speed: float = 5.0

var _controller: XRController3D
var _btn_state: bool = false

@onready var _camera := XRHelpers.get_xr_camera(self)
@onready var _left_controller := XRHelpers.get_left_controller(self)
@onready var _right_controller := XRHelpers.get_right_controller(self)

# called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	if controller == Controller.LEFT:
		_controller = _left_controller
	else:
		_controller = _right_controller

# called by player body while iterating movement providers
func physics_movement(delta: float, player_body: XRToolsPlayerBody, disabled: bool):
	# disable lerp if requested or if selected controller is inactive
	if disabled or !enabled or !_controller.get_is_active():
		is_active = false
		return
	
	# detect press of lerp button
	var btn_old = _btn_state
	_btn_state = _controller.is_button_pressed(lerp_button)
	if _btn_state and !btn_old:
		is_active = !is_active

	if !is_active:
		return

	# interpolate to target position
	var v = Vector3(0, 1, 0)
	player_body.velocity = player_body.move_body(v)
	
	# return true to indicate to player body that this was an exclusive movement
	# gravity & ground physics wont be applied
	return true

# verify the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	if !XRHelpers.get_xr_camera(self):
		warnings.append("Unable to find XRCamera3D")

	if !XRHelpers.get_left_controller(self):
		warnings.append("Unable to find left XRController3D node")

	if !XRHelpers.get_right_controller(self):
		warnings.append("Unable to find left XRController3D node")

	return warnings
