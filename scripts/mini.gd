extends Node

# Mini minifies a world tree to enable more dramatic interaction (e.g. moving objects long distances and through walls)
# it's designed to work with the Substitution movement provider for greater avatar manipulation
# the avatar_spawn and start_sub signals should be connected to scale_down and scale_up
# after scaling down, the mini world is attached to the configured "hold controller"
# the "manipulate controller" may then translate and rotate the mini world while interacting with the scene

@export var player: XRToolsPlayerBody
@export var hold_controller: XRController3D
@export var manipulate_controller: XRController3D
@export var world: Node3D
@export var mini_scale := 0.05
@export var interpolation_speed := 2.0
@export var translate_speed := 3.0
@export var rotate_speed := 3.0
@export var enabled := true

var world_in_hand := false
var target_world_xform: Transform3D
var lerp_t := 0.0

@onready var world_parent: Node3D = world.get_parent()

func _ready():
	pass

func _process(delta):
	pass
	
func _physics_process(delta):
	if !enabled: return
	
	if lerp_t < 1:
		world.transform = world.transform.interpolate_with(target_world_xform, lerp_t)
		lerp_t += delta * interpolation_speed
		return
	elif !world_in_hand and !player.enabled:
		# world is back to normal scale, unfreeze
		player.set_enabled(true)
		
	if world_in_hand:
		# manipulate mini world
		# translation and rotation done one at a time
		var input = manipulate_controller.get_vector2('primary')
		if abs(input[1]) > abs(input[0]):
			world.transform = world.transform.translated(Vector3(0, 0, -input[1] * translate_speed * delta))
		else:
			world.global_transform = world.global_transform.rotated_local(Vector3(0, 1, 0), input[0] * rotate_speed * delta)
	
func scale_down():
	if !enabled: return
	# freeze player movement
	player.set_enabled(false)
	# minify world & attach to controller
	world.reparent(hold_controller)
	world_in_hand = true
	target_world_xform = Transform3D().scaled(Vector3(mini_scale, mini_scale, mini_scale))
	lerp_t = 0
	
func scale_up():
	if !enabled: return
	# restore world
	world.reparent(world_parent)
	world_in_hand = false
	target_world_xform = Transform3D()
	lerp_t = 0
