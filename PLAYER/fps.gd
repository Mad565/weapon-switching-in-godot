extends CharacterBody3D

# movement speed.
var speed 
var Default_speed = 5.0
# air accel stands for acceleration in hanppening in air. 
# default accel stands for acceleration in not hanppening in air but instead on ground.
const ACCEL_DEFAULT = 7.0
const ACCEL_AIR = 1.0
#These constants define two acceleration values: 
#These values control how quickly the player speeds up and slows down in different contexts.
# ACCEL_DEFAULT for when the player is on the ground, and ACCEL_AIR for when the player is in the air. 
# @onrady is about the current acceleration.
@onready var accel = ACCEL_DEFAULT
#Gets the gravity and jumping variables.
var gravity = 9.8
var JUMP_VELOCITY = 3.0
# lowest height and maximum.
var default_height = 2.0
var crouch_height = 1.0
# lowest height and maximum transition speed.
var crouch_speed = 20.0
# mouse sensitivity.
var mouse_sense = 0.1
#improtant variables for player movement.
var snap
var direction = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var pcap = $CollisionShape3D
@onready var ray = $RayCast3D
# called when the node enters the scene tree for the first time.
func _ready():
	#hides the cursor.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#gets mouse input
func _input(event):
	#get mouse input for camera rotation and clamp the up and down rotations.
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# called every frame. 'delta' is the elapsed time since the previous frame.
# also this will handle all the players movement and physics.
func _physics_process(delta):
	# if escape is pressed it will show the mouse cursor.
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#get keyboard input.
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	speed = Default_speed
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("s") - Input.get_action_strength("w")
	var h_input = Input.get_action_strength("d") - Input.get_action_strength("a")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	# adds crouching to the player.
	crouch(delta)
	#jumping and gravity.
	# Add the gravity.
	if not is_on_floor():
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		velocity.y -= gravity * delta
	else:
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		velocity.y -= JUMP_VELOCITY 
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		snap = Vector3.ZERO
		accel = ACCEL_AIR
		velocity.y = JUMP_VELOCITY 
	#make it move
	# Current velocity vector (typically meters per second), used and modified during calls to move_and_slide().
	velocity = velocity.lerp(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	# Moves the body based on velocity.
	move_and_slide()

# the crouch function.
func crouch(delta):
	var raying = false
	if ray.is_colliding():
		raying = true
	if Input.is_action_pressed("crouch"):
		speed = Default_speed
		JUMP_VELOCITY = 0.0
		pcap.shape.height -= crouch_speed * delta
	elif not raying:
		JUMP_VELOCITY = 3.0 
		pcap.shape.height += crouch_speed * delta
	pcap.shape.height =  clamp(pcap.shape.height, crouch_height,default_height)
