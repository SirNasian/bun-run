class_name Player extends CharacterBody2D


const COYOTE_TIME = 0.05
const INPUT_BUFFER_TIME = 0.1
const MAX_SPEED = 256
const GRAVITY = 1024

var multiplayer_id = 0
var can_jump = self.COYOTE_TIME

var input: Dictionary = {
	"left": 0.0,
	"right": 0.0,
	"jump": 0.0,
}

static func instantiate(_id: int) -> Player:
	var player = preload("res://entities/player/player.tscn").instantiate()
	player.multiplayer_id = _id
	player.get_node("Label").text = str(_id)
	return player


@rpc("any_peer", "call_local", "unreliable_ordered")
func send_input(new_input: Dictionary) -> void:
	self.input = new_input


@rpc("reliable")
func send_position(_position: Vector2, _velocity: Vector2) -> void:
	self.position = Vector2(_position.x, _position.y)
	self.velocity = _velocity


func _ready() -> void:
	var multiplayer_position_timer = Timer.new()
	multiplayer_position_timer.timeout.connect(_multiplayer_position_timer_timeout)
	self.add_child(multiplayer_position_timer)
	multiplayer_position_timer.start(1)


func _process(delta: float) -> void:
	var input_x = float(input.right - input.left)
	self.update_coyote_time(delta)
	self.update_velocity(input_x, delta)
	self.update_animation()
	self.move_and_slide()


func _input(event: InputEvent) -> void:
	if ((!event.is_action_type())): return
	if (self.multiplayer_id != self.multiplayer.get_unique_id()): return

	var new_input = self.input.duplicate()

	if (event.is_action("player_left")):
		new_input.left = event.get_action_strength("player_left") if (event.is_pressed()) else 0.0

	if (event.is_action("player_right")):
		new_input.right = event.get_action_strength("player_right") if (event.is_pressed()) else 0.0

	if (event.is_action_pressed("player_jump")):
		new_input.jump = self.INPUT_BUFFER_TIME

	if (self.input != new_input):
		self.send_input.rpc(new_input)


func _multiplayer_position_timer_timeout() -> void:
	self.send_position.rpc(self.position, self.velocity)


func update_coyote_time(delta: float) -> void:
	if (self.is_on_floor()):
		self.can_jump = self.COYOTE_TIME
	else:
		self.can_jump = max(0, self.can_jump - delta)
		self.input.jump = max(0, self.input.jump - delta)


func update_velocity(input_x: float, delta: float) -> void:
	self.velocity.x = lerp(self.velocity.x, input_x * self.MAX_SPEED, delta * (1 + (int(self.is_on_floor()) * 3)))
	if (self.input.jump && self.can_jump):
		self.input.jump = 0
		self.can_jump = 0
		self.velocity.y = -256
	if (!self.is_on_floor()):
		self.velocity.y += self.GRAVITY * delta


func update_animation() -> void:
	var sprite = $AnimatedSprite2D as AnimatedSprite2D
	sprite.flip_h = sprite.flip_h if (!self.velocity.x) else (self.velocity.x > 0)
	if (self.is_on_floor()):
		sprite.play("run" if (input.left || input.right) else "idle")
	else:
		sprite.animation = "jump"
		sprite.frame = 0 if (self.velocity.y < 0) else 1
