class_name Player extends CharacterBody2D


@export var deadzone: float = 0.2
@export var jump_force: float = 256.0

const COYOTE_TIME: float = 0.05
const INPUT_BUFFER_TIME: float = 0.05
const MAX_SPEED: float = 256.0

enum INPUT { LEFT, RIGHT, JUMP }
static var ID: int = 0

var id: int = 0
var can_jump: float = COYOTE_TIME
var input: Array = [ 0.0, 0.0, 0.0 ];


static func instantiate() -> Player:
	var player = preload("res://entities/player/player.tscn").instantiate()
	ID += 1
	player.id = ID
	player.name = "Player-%d" % ID
	return player


func serialize() -> Array:
	return [
		id,
		get_multiplayer_authority(),
		position,
		velocity,
		can_jump,
		jump_force,
		input,
	]


func deserialize(data: Array) -> Player:
	id = data[0]
	name = "Player-%d" % data[0]
	set_multiplayer_authority(data[1])
	position = data[2]
	velocity = data[3]
	can_jump = data[4]
	jump_force = data[5]
	input = data[6]
	return self


func _ready() -> void:
	Game.instance.sync.connect(_on_sync)
	if (is_multiplayer_authority()):
		$Camera2D.enabled = true
		$Camera2D.make_current()


func _process(delta: float) -> void:
	update_coyote_time(delta)
	update_animation()


func _physics_process(delta: float) -> void:
	update_velocity(input[INPUT.RIGHT] - input[INPUT.LEFT], delta)
	move_and_slide()


func _input(event: InputEvent) -> void:
	var should_sync: bool = false
	if (!is_multiplayer_authority()): return

	if (event is InputEventScreenTouch):
		input[INPUT.LEFT] = 0.0
		input[INPUT.RIGHT] = 0.0
		should_sync = true

	if (event is InputEventScreenDrag):
		should_sync = true

		if (event.screen_relative.y < -24):
			input[INPUT.JUMP] = INPUT_BUFFER_TIME

		input[INPUT.LEFT] -= event.screen_relative.x / 128.0
		input[INPUT.RIGHT] += event.screen_relative.x / 128.0

	if (event.is_action("player_left")):
		var strength = event.get_action_strength("player_left")
		input[INPUT.LEFT] = strength if (strength > deadzone) else 0.0
		should_sync = true

	if (event.is_action("player_right")):
		var strength = event.get_action_strength("player_right")
		input[INPUT.RIGHT] = strength if (strength > deadzone) else 0.0
		should_sync = true

	if (event.is_action_pressed("player_jump")):
		input[INPUT.JUMP] = INPUT_BUFFER_TIME
		should_sync = true

	input[INPUT.LEFT] = clamp(input[INPUT.LEFT], 0.0, 1.0)
	input[INPUT.RIGHT] = clamp(input[INPUT.RIGHT], 0.0, 1.0)

	if (should_sync):
		sync_input.rpc(input)


func _on_sync() -> void:
	if (is_multiplayer_authority()):
		sync_kinematics.rpc(position, velocity)
		sync_input.rpc(input)


@rpc("reliable")
func sync_input(updated_input: Array) -> void:
	input = updated_input


@rpc("unreliable_ordered")
func sync_kinematics(updated_position: Vector2, updated_velocity: Vector2):
	position = updated_position
	velocity = updated_velocity


func update_coyote_time(delta: float) -> void:
	if (is_on_floor()):
		can_jump = COYOTE_TIME
	else:
		can_jump = max(0, can_jump - delta)
		input[INPUT.JUMP] = max(0, input[INPUT.JUMP] - delta)


func update_velocity(input_x: float, delta: float) -> void:
	velocity.x = lerp(velocity.x, input_x * MAX_SPEED, delta * (1 + (int(is_on_floor()) * 3)))
	if (input[INPUT.JUMP] && can_jump):
		input[INPUT.JUMP] = 0
		can_jump = 0
		velocity.y = -jump_force
	if (!is_on_floor()):
		velocity += get_gravity() * delta


func update_animation() -> void:
	var sprite = $AnimatedSprite2D as AnimatedSprite2D
	sprite.flip_h = sprite.flip_h if (!velocity.x) else (velocity.x > 0)
	if (is_on_floor()):
		sprite.play("run" if (input[INPUT.LEFT] || input[INPUT.RIGHT]) else "idle")
	else:
		sprite.animation = "jump"
		sprite.frame = 0 if (velocity.y < 0) else 1
