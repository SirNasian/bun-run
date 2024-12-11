class_name Player extends CharacterBody2D


const COYOTE_TIME: float = 0.05
const INPUT_BUFFER_TIME: float = 0.1
const MAX_SPEED: float = 256.0

var can_jump: float = self.COYOTE_TIME

var input: Array = [ 0.0, 0.0, 0.0 ];
enum INPUT { LEFT, RIGHT, JUMP }


static func instantiate(id: int) -> Player:
	var player = preload("res://entities/player/player.tscn").instantiate()
	player.set_multiplayer_authority(id)
	player.name = str("player-", id)
	player.get_node("Label").text = str(id)
	return player


func _ready() -> void:
	Utils.create_sync_timer(self, _on_kinematics_sync_timer)
	$Camera2D.enabled = self.is_multiplayer_authority()


func _process(delta: float) -> void:
	self.update_coyote_time(delta)
	self.update_animation()


func _physics_process(delta: float) -> void:
	self.update_velocity(self.input[INPUT.RIGHT] - self.input[INPUT.LEFT], delta)
	self.move_and_slide()


func _input(event: InputEvent) -> void:
	if ((!event.is_action_type())): return
	if (!self.is_multiplayer_authority()): return

	if (event.is_action("player_left")):
		var strength = event.get_action_strength("player_left")
		self.input[INPUT.LEFT] = strength if (strength > 0.2) else 0.0

	if (event.is_action("player_right")):
		var strength = event.get_action_strength("player_right")
		self.input[INPUT.RIGHT] = strength if (strength > 0.2) else 0.0

	if (event.is_action_pressed("player_jump")):
		self.input[INPUT.JUMP] = self.INPUT_BUFFER_TIME

	self.sync_input.rpc(self.input)


func _on_kinematics_sync_timer() -> void:
	if (self.is_multiplayer_authority()):
		self.sync_kinematics.rpc(self.position, self.velocity)
		self.sync_input.rpc(self.input)


@rpc("reliable")
func sync_input(updated_input: Array) -> void:
	self.input = updated_input


@rpc("unreliable_ordered")
func sync_kinematics(updated_position: Vector2, updated_velocity: Vector2):
	self.position = updated_position
	self.velocity = updated_velocity


func update_coyote_time(delta: float) -> void:
	if (self.is_on_floor()):
		self.can_jump = self.COYOTE_TIME
	else:
		self.can_jump = max(0, self.can_jump - delta)
		self.input[INPUT.JUMP] = max(0, self.input[INPUT.JUMP] - delta)


func update_velocity(input_x: float, delta: float) -> void:
	self.velocity.x = lerp(self.velocity.x, input_x * self.MAX_SPEED, delta * (1 + (int(self.is_on_floor()) * 3)))
	if (self.input[INPUT.JUMP] && self.can_jump):
		self.input[INPUT.JUMP] = 0
		self.can_jump = 0
		self.velocity.y = -256
	if (!self.is_on_floor()):
		self.velocity += self.get_gravity() * delta


func update_animation() -> void:
	var sprite = $AnimatedSprite2D as AnimatedSprite2D
	sprite.flip_h = sprite.flip_h if (!self.velocity.x) else (self.velocity.x > 0)
	if (self.is_on_floor()):
		sprite.play("run" if (self.input[INPUT.LEFT] || self.input[INPUT.RIGHT]) else "idle")
	else:
		sprite.animation = "jump"
		sprite.frame = 0 if (self.velocity.y < 0) else 1
