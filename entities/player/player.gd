extends CharacterBody2D

const MAX_SPEED = 256
const GRAVITY = 1024

var input_left = 0
var input_right = 0

func _process(delta: float) -> void:
	var input_x = float(input_left + input_right)

	if (self.is_on_floor()):
		self.velocity.x = lerp(self.velocity.x, input_x * self.MAX_SPEED, delta * 4)
	else:
		self.velocity.y += self.GRAVITY * delta

	self.move_and_slide()

func _input(event: InputEvent) -> void:
	if (!event.is_action_type()): pass
	if (event.is_action_pressed("player_left")):   input_left  = -event.get_action_strength("player_left")
	if (event.is_action_released("player_left")):  input_left  = 0
	if (event.is_action_pressed("player_right")):  input_right = event.get_action_strength("player_right")
	if (event.is_action_released("player_right")): input_right = 0
	if (event.is_action_pressed("player_jump")):
		if (self.is_on_floor()): self.velocity.y = -256
