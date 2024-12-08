extends CharacterBody2D

const MAX_SPEED = 256
const GRAVITY = 1024

var input = {
	"left": 0,
	"right": 0,
	"jump": 0,
}

func _process(delta: float) -> void:
	var input_x = float(input.left + input.right)
	self.update_velocity(input_x, delta)
	self.update_animation()
	self.move_and_slide()

func _input(event: InputEvent) -> void:
	if (!event.is_action_type()): pass
	if (event.is_action_pressed("player_left")):   input.left  = -event.get_action_strength("player_left")
	if (event.is_action_released("player_left")):  input.left  = 0
	if (event.is_action_pressed("player_right")):  input.right = event.get_action_strength("player_right")
	if (event.is_action_released("player_right")): input.right = 0
	if (event.is_action_pressed("player_jump")):   input.jump  = 1 if (self.is_on_floor()) else 0

func update_velocity(input_x: float, delta: float) -> void:
	if (self.is_on_floor()):
		if (self.input.jump):
			self.input.jump = 0
			self.velocity.y = -256
		self.velocity.x = lerp(self.velocity.x, input_x * self.MAX_SPEED, delta * 4)
	else:
		self.velocity.y += self.GRAVITY * delta
		self.velocity.x = lerp(self.velocity.x, input_x * self.MAX_SPEED, delta)

func update_animation() -> void:
	var sprite = $AnimatedSprite2D as AnimatedSprite2D
	sprite.flip_h = sprite.flip_h if (!self.velocity.x) else (self.velocity.x > 0)
	if (self.is_on_floor()):
		sprite.play("run" if (input.left || input.right) else "idle")
	else:
		sprite.animation = "jump"
		sprite.frame = 0 if (self.velocity.y < 0) else 1
