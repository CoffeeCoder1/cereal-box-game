class_name MazePlayer extends RigidBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = 400.0

var _floor_rotation: float = 0.0

@onready var jump_cooldown_timer: Timer = $JumpCooldownTimer


func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC


func _process(delta: float) -> void:
	freeze = not is_multiplayer_authority()


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Handle jump.
	# TODO: Make this better
	if Input.is_action_just_pressed("move_jump"):# and jump_cooldown_timer.is_stopped():
		apply_central_impulse(Vector2.UP * JUMP_VELOCITY)
		jump_cooldown_timer.start()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		apply_central_force((Vector2.RIGHT * direction * SPEED).rotated(_floor_rotation))


func set_floor_rotation(new_rotation: float) -> void:
	_floor_rotation = new_rotation
