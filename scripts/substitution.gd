@tool
class_name Substitution
extends XRToolsMovementProvider

# Substitution is a custom XR Tools movement provider
# provides teleportation with rapid transition via linear interpolation
# pressing the configured button drops an avatar at the player's position
# pressing the button a second time teleports the player to the avatar

signal avatar_spawn(player_body: XRToolsPlayerBody) # emitted when player drops an avatar
signal start_sub(player_body: XRToolsPlayerBody) # emitted when player requests to substitute avatar
signal end_sub(player_body: XRToolsPlayerBody) # emitted when player replaces avatar

@export var order: int = 1 # movement provider priority (lowest runs first)
@export var button: String = "trigger_click"
@export var speed: float = 20 # interpolation speed while entering & exiting avatar
@export var avatar: Node3D # avatar to interpolate towards
@export var avatar_offset: float = 0 # distance from avatar to stop interpolation

@onready var _player := XRHelpers.get_xr_origin(self).get_node('PlayerBody')

func _ready():
	super()
	avatar.visible = false
	
func _process(delta):
	pass
	
func _physics_process(delta):
	pass

# called by player body while iterating movement providers
func physics_movement(delta: float, player_body: XRToolsPlayerBody, disabled: bool):
	if disabled or !enabled or !avatar:
		is_active = false
		return
	
	if is_active and avatar.visible:
		var distance_to_avatar := player_body.global_position.distance_to(avatar.global_position)
		if distance_to_avatar < max(avatar_offset, 0.25):
			# within offset to avatar
			# stop player, disable lerp, and hide avatar
			player_body.velocity = player_body.move_body(Vector3(0, 0, 0))
			is_active = false
			avatar.visible = false
			end_sub.emit(player_body)
		else:
			# interpolate towards avatar
			var lerp_dir := player_body.global_position.direction_to(avatar.global_position)
			player_body.velocity = player_body.move_body(lerp_dir * speed)
		
		# return true to indicate to player body that this was an exclusive movement
		# gravity & ground physics wont be applied
		return true

func _on_button_pressed(name: String):
	if name == button:
		if avatar.visible:
			# avatar is present, activate lerp
			if !is_active:
				start_sub.emit(_player)
				is_active = true
		else:
			# drop avatar at player position
			avatar.global_transform = _player.global_transform
			avatar.visible = true
			avatar_spawn.emit(_player)

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
