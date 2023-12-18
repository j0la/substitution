extends Node

# Mini is designed to work with the Substitution movement provider
# when an avatar is spawned, the configured world tree is scaled down and attached to the configured controller
# the other controller may then grab and manipulate the avatar in the mini world before performing a substitution
# using a mini world enables more extreme avatar manipulation like substituting over long distances or through walls
# scaling up and down are triggered through signals

@export var hold_controller: XRController3D
@export var manipulate_controller: XRController3D
@export var world: Node3D # world tree to minify
@export var mini_scale: float = 0.1
@export var translate_speed: float = 3.0
@export var rotate_speed: float = 3.0

var world_in_hand := false
var deadzone = 0.1

@onready var world_parent: Node3D = world.get_parent()

func _ready():
	pass

func _process(delta):
	pass
	
func _physics_process(delta):
	if world_in_hand:
		var input = manipulate_controller.get_vector2('primary')
		if abs(input[1]) > deadzone:
			world.transform = world.transform.translated(Vector3(0, 0, -input[1] * translate_speed * delta))
		if abs(input[0]) > deadzone:
			world.global_transform = world.global_transform.rotated_local(Vector3(0, 1, 0), input[0] * rotate_speed * delta)
	
func scale_down(player_body: XRToolsPlayerBody):
	# freeze player movement
	player_body.set_enabled(false)
	# minify world & attach to controller
	world.set_scale(Vector3(mini_scale, mini_scale, mini_scale))
	world.reparent(hold_controller)
	world_in_hand = true
	world.set_position(Vector3(0, 0, 0))
	world.set_rotation_degrees(Vector3(0, 0, 0))
	
func scale_up(player_body: XRToolsPlayerBody):
	# restore world
	world.reparent(world_parent)
	world_in_hand = false
	world.set_identity()
	# unfreeze player
	player_body.set_enabled(true)
