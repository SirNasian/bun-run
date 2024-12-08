class_name Player extends CharacterBody2D


const COYOTE_TIME = 0.05
const INPUT_BUFFER_TIME = 0.1
const MAX_SPEED = 256
const GRAVITY = 1024

var can_jump = self.COYOTE_TIME

@export var input: Dictionary = {
	"left": 0.0,
	"right": 0.0,
	"jump": 0.0,
}

static func instantiate(id: int) -> Player:
	var player = preload("res://entities/player/player.tscn").instantiate()
	player.set_multiplayer_authority(id)
	player.name = str("player-", id)
	player.get_node("Label").text = str(id)
	return player

func _ready() -> void:
	$Camera2D.enabled = self.is_multiplayer_authority()

func _process(delta: float) -> void:
	var input_x = float(input.right - input.left)
	self.update_coyote_time(delta)
	self.update_velocity(input_x, delta)
	self.update_animation()
	self.move_and_slide()


func _input(event: InputEvent) -> void:
	if ((!event.is_action_type())): return
	if (!self.is_multiplayer_authority()): return

	if (event.is_action("player_left")):
		var strength = event.get_action_strength("player_left")
		self.input.left = strength if (strength > 0.2) else 0.0

	if (event.is_action("player_right")):
		var strength = event.get_action_strength("player_right")
		self.input.right = strength if (strength > 0.2) else 0.0

	if (event.is_action_pressed("player_jump")):
		self.input.jump = self.INPUT_BUFFER_TIME

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
