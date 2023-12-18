@tool
class_name Substitution
extends XRToolsMovementProvider

# substitution is a custom XR Tools movement provider
# provides teleportation with rapid transition via linear interpolation
# pressing the configured button drops an avatar at the player's position
# pressing the button a second time teleports the player to the avatar

signal avatar_spawn # emitted when player drops an avatar
signal avatar_sub # emitted when player replaces avatar

enum Controller { LEFT, RIGHT }

@export var order: int = 1 # movement provider priority (lowest runs first)
@export var controller: Controller = Controller.RIGHT
@export var button: String = "trigger_click"
@export var speed: float = 20 # interpolation speed while entering & exiting avatar
@export var avatar: Node3D # avatar to interpolate towards
@export var avatar_offset: float = 0 # distance from avatar to stop interpolation

var _controller: XRController3D
var _button_state: bool = false

@onready var _camera := XRHelpers.get_xr_camera(self)
@onready var _left_controller := XRHelpers.get_left_controller(self)
@onready var _right_controller := XRHelpers.get_right_controller(self)

func _ready():
	super()
	
	if controller == Controller.LEFT:
		_controller = _left_controller
	else:
		_controller = _right_controller
		
	# hide avatar initially
	avatar.visible = false

# called by player body while iterating movement providers
func physics_movement(delta: float, player_body: XRToolsPlayerBody, disabled: bool):
	# disable lerp if requested, if selected controller is inactive, or if avatar is unassigned
	if disabled or !enabled or !_controller.get_is_active() or !avatar:
		is_active = false
		return
	
	# detect button press
	var btn_old = _button_state
	_button_state = _controller.is_button_pressed(button)
	if _button_state and !btn_old:
		if !avatar.visible:
			# drop avatar at player position
			avatar.global_transform = player_body.global_transform
			avatar.visible = true
			avatar_spawn.emit()
			# stop here, next press will execute lerp to avatar
			return
		is_active = !is_active
	
	if is_active and avatar.visible:
		var distance_to_avatar := player_body.global_position.distance_to(avatar.global_position)
		if distance_to_avatar < max(avatar_offset, 0.25):
			# within offset to avatar
			# stop player, disable lerp, and hide avatar
			player_body.velocity = player_body.move_body(Vector3(0, 0, 0))
			is_active = false
			avatar.visible = false
			avatar_sub.emit()
		else:
			# interpolate towards avatar
			var lerp_dir := player_body.global_position.direction_to(avatar.global_position)
			player_body.velocity = player_body.move_body(lerp_dir * speed)
		
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
