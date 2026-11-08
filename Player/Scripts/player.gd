class_name Player extends CharacterBody2D

const GRAVITY = 1700
const MAX_SPEED = 500
const JUMP_POWER = 700
const ACC = 2000
#If i dont want Bhop
const FRICTION = 300

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum {IDLE, WALK, AIR, DEAD, ATTACK}

var state = IDLE
var can_jump: bool = true
var want_to_jump: bool = false
#Används för att charaktärens sprite inte ska teleporteras omkring när flip h är sant
var saved_position = get_global_position()

############################# Game Loop #############################
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		AIR:
			_air_state(delta)
		DEAD:
			_dead_state(delta)
		ATTACK:
			_attack_state(delta)
			
################################# Privet Help Functions ##############################
#Updates the direction of the sprite
func _update_direction(input_x: float) -> void:
	if input_x < 0:
		anim_sprite.flip_h = true
		anim_sprite.position.x = -34
	elif input_x > 0:
		anim_sprite.flip_h = false
		
		
#Makes the character move depending on the value of input_x
func _movement(input_x: float, delta:float) -> void:
	if input_x != 0:
		velocity.x = move_toward(velocity.x, input_x * MAX_SPEED, ACC * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACC*delta)
	
	velocity.y += GRAVITY *delta
	move_and_slide()



#################################### State Functions ####################################

func _idle_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		_enter_air_state(true)
	var input_x = Input.get_axis("Left", "Right")
	
	#utför rörelsen
	_update_direction(input_x)
	_movement(input_x, delta)
	
	if not is_on_floor():
		_enter_air_state(false)
	elif velocity.length() != 0:
		_enter_walk_state()
		
		
func _walk_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		_enter_air_state(true)
	var input_x = Input.get_axis("Left", "Right")
	
	_update_direction(input_x)
	_movement(input_x, delta)
	
	if not is_on_floor():
		_enter_air_state(false)
	elif velocity.length() == 0:
		_enter_idle_state()
		
func _air_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump") and can_jump:
		can_jump = false
		velocity.y = -JUMP_POWER
	elif Input.is_action_just_pressed("Jump") and  not can_jump:
		want_to_jump = true
		#jump_buffer.start()
	var input_x = Input.get_axis("Left", "Right")
	
	_update_direction(input_x)
	_movement(input_x, delta)
	
	if is_on_floor() and want_to_jump:
		_enter_air_state(true)
	elif is_on_floor() and velocity.length() > 0:
		_enter_walk_state()
	elif is_on_floor():
		_enter_idle_state()

func _dead_state(_delta: float) -> void:
	pass

func _attack_state(_delta: float) -> void:
	pass

############################# Enter State Functions #################################


func _enter_idle_state() -> void:
	state = IDLE 
	anim_sprite.play("Idle")
	
func _enter_walk_state() -> void:
	state = WALK
	anim_sprite.play("Run")
	
func _enter_air_state(jumping:bool) -> void:
	state = AIR
	anim_sprite.play("Jump")
	want_to_jump = false
	if jumping:
		velocity.y = -JUMP_POWER
		can_jump = false
	else:
		can_jump = true
		#coyote_timer.start()
		
		
func _enter_dead_state() -> void:
	state = DEAD
	anim_sprite.play("Death")

func _enter_attack_state() -> void:
	state = ATTACK

####################################### Signals ############################################
