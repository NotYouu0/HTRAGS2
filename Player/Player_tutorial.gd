



extends KinematicBody

const JOY_DEADZONE = 0.2
const JOY_AXIS_RESCALE = 1.0 / (1.0 - JOY_DEADZONE)
const JOY_ROTATION_MULTIPLIER = 200.0 * PI / 180.0

export  var speed: int = 10
export  var can_move: bool = true
export  var can_look: bool = true
export  var can_sprint: bool = true
export  var can_jump: bool = true
export  var can_crouch: bool = true
export  var can_interact: bool = true
export  var cutscene: bool = false

var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump_power = 10
var full_contact = false

var mouse_sensitivity = SettingsManager.mouse_sensitivity

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

var object

var is_crouching = false
var looked = false

var moved_forward = false
var moved_left = false
var moved_right = false
var moved_backward = false
var moved_all_dirs = false

onready var head = $Head
onready var camera = $Head / Camera
onready var ground_check = $GroundCheck
onready var interaction_ray = $Head / Camera / InteractionRay
onready var collision = $Body
onready var foot_collision = $Foot
onready var animation = $Head / Camera / AnimationPlayer

onready var ui_root = $UILayer / UI
onready var ui_hand = $UILayer / UI / Hand
onready var ui_speech = $UILayer / UI / Speech
onready var ui_crosshair = $UILayer / UI / Crosshair

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera.fov = SettingsManager.camera_fov

func _input(event):
	if event is InputEventMouseMotion and can_look:
		rotate_y(deg2rad( - event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad( - event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad( - 89), deg2rad(89))

func _physics_process(delta):
	direction = Vector3()
	
	full_contact = ground_check.is_colliding()
	
	collision.disabled = cutscene
	foot_collision.disabled = cutscene
	
	SpeedrunTimer.timer_on = not cutscene
	
	
	if head.rotation != Vector3( - 0, 0, 0) and looked == false:
		$"../VoiceClips/Amazing".play()
		looked = true
	
	
	if moved_forward and moved_backward and moved_left and moved_right and moved_all_dirs == false:
		$"../VoiceClips/Speechless".play()
		moved_all_dirs = true
	
	
	if interaction_ray.is_colliding():
		object = interaction_ray.get_collider()
		if object.has_method("interact"):
			ui_hand.visible = true
			ui_crosshair.visible = false
		else:
			ui_hand.visible = false
			ui_crosshair.visible = true
	else:
		ui_hand.visible = false
		ui_crosshair.visible = true
	
	
	
	if not cutscene:
		if not is_on_floor():
			gravity_vec += Vector3.DOWN * gravity * delta
			h_acceleration = air_acceleration
		elif is_on_floor() and full_contact:
			gravity_vec = - get_floor_normal() * gravity
			h_acceleration = normal_acceleration
		else:
			gravity_vec = - get_floor_normal()
			h_acceleration = normal_acceleration
	
	
	if can_move:
		if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()) and can_jump:
			gravity_vec = Vector3.UP * jump_power
			GlobalStats.times_jumped += 1
		
		if can_sprint:
			if Input.is_action_pressed("sprint") and not is_crouching:
				
				speed = 20
			if Input.is_action_just_released("sprint"):
				
				speed = 10
		
		if can_crouch:
			
			if Input.is_action_just_pressed("crouch"):
				
				scale.y = 0.5
				speed = 5
				is_crouching = true
			if Input.is_action_just_released("crouch"):
				scale.y = 1
				speed = 10
				is_crouching = false
			
		
		if Input.is_action_pressed("move_forward"):
			direction -= transform.basis.z
			moved_forward = true
		elif Input.is_action_pressed("move_backward"):
			direction += transform.basis.z
			moved_backward = true
		if Input.is_action_pressed("move_left"):
			direction -= transform.basis.x
			moved_left = true
		elif Input.is_action_pressed("move_right"):
			direction += transform.basis.x
			moved_right = true
		
		
	
	if can_look:
		var xAxis = Input.get_joy_axis(0, JOY_AXIS_2)
		if abs(xAxis) > JOY_DEADZONE:
			if xAxis > 0:
				xAxis = (xAxis - JOY_DEADZONE) * JOY_AXIS_RESCALE
			else:
				xAxis = (xAxis + JOY_DEADZONE) * JOY_AXIS_RESCALE
			rotate_object_local(Vector3.UP, - xAxis * delta * JOY_ROTATION_MULTIPLIER)
		
		var yAxis = Input.get_joy_axis(0, JOY_AXIS_3)
		if abs(yAxis) > JOY_DEADZONE:
			if yAxis > 0:
				yAxis = (yAxis - JOY_DEADZONE) * JOY_AXIS_RESCALE
			else:
				yAxis = (yAxis + JOY_DEADZONE) * JOY_AXIS_RESCALE
			head.rotate_object_local(Vector3.RIGHT, - yAxis * delta * JOY_ROTATION_MULTIPLIER)
			head.rotation.x = clamp(head.rotation.x, - 1.0, 1.0)
	
	
	
	if Input.is_action_just_pressed("interact") and can_interact:
		if interaction_ray.is_colliding():
			
			if object.has_method("interact"):
				object.interact()
				GlobalStats.objects_interacted += 1
	
	
	
	if direction != Vector3():
		
		if ground_check.is_colliding() and SettingsManager.head_bobbing:
			animation.play("Head Bob")
	
	
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement + get_floor_velocity(), Vector3.UP)
