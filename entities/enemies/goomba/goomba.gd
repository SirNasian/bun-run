class_name Goomba extends CharacterBody2D


const MAX_SPEED = 128.0

var state = {
	"alive" = true,
	"direction" = 1,
}


static func instantiate(_data: Dictionary) -> Goomba:
	return preload("res://entities/enemies/goomba/goomba.tscn").instantiate()


func _ready() -> void:
	$AnimatedSprite2D.play("walk")


func _process(_delta) -> void:
	if (!self.state.alive):
		$AnimatedSprite2D.play("die")


func _physics_process(delta: float) -> void:
	if (!self.is_on_floor()):
		velocity += get_gravity() * delta

	if (!self.state.alive):
		velocity.x = 0.0
		return

	if (self.is_on_wall()):
		self.state.direction = -self.state.direction

	velocity.x = lerp(velocity.x, self.state.direction * MAX_SPEED, min(delta * 4, 1))
	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	if (self.state.alive && (body is Player) && (body.velocity.y > 0)):
		body.velocity.y = -256.0
		if (self.is_multiplayer_authority()):
			self.state.alive = false
			self.sync_state.rpc(self.state, self.position, self.velocity)


func _on_state_sync() -> void:
	if (self.is_multiplayer_authority()):
		self.sync_state.rpc(self.state, self.position, self.velocity)


@rpc("unreliable_ordered")
func sync_state(_state: Dictionary, _position: Vector2, _velocity: Vector2):
	self.state = _state
	self.position = _position
	self.velocity = _velocity
