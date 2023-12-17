extends Node

var astral_mode := false
var interp_target = null
var interp_progress = 0

@onready var _flight := $"../XROrigin3D/MovementFlight"
@onready var _camera := $"../XROrigin3D/XRCamera3D"
@onready var _player := $"../XROrigin3D/PlayerBody"
@onready var _avatar := $"../World/Avatar"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
	
func _physics_process(delta: float):
	pass

func _on_button_pressed(name: String) -> void:
	print("pressed: " + name)
	
#	if name == 'ax_button':
#		astral_mode = !astral_mode
#		enter_astral() if astral_mode else exit_astral()
	
func _on_button_released(name: String) -> void:
	print("released: " + name)
	
func enter_astral() -> void:
	# drop avatar at player's location
#	_avatar.global_position = _camera.global_position
#	_avatar.visible = true
	# move player up a bit
#	var target = _camera.global_transform
#	target.origin.y += 2
#	set_interp_target(target)
	# enable avatar collision
#	_avatar.collision_layer = 0b00000000_00000000_00000000_00000100
	# enable flight mode
	_flight.set_flying(true)
	# shrink the world & fix in front of player
	
func exit_astral() -> void:
	# unlock mini world & scale back to normal
	# hide avatar, disable collision
#	_avatar.visible = false
#	_avatar.collision_layer = 0
	# disable flight mode
	_flight.set_flying(false)
	# teleport player to avatar
#	_player.teleport(_avatar.global_transform)
	
func set_interp_target(xform: Transform3D) -> void:
#	_player.teleport(xform)
	interp_target = xform
	interp_progress = 0
