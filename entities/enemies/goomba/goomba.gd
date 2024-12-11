class_name Goomba extends CharacterBody2D


const MAX_SPEED: float = 128.0
var alive: bool = true
var death_timer: float = 1.0
var direction: int = 1


static func instantiate(_data: Dictionary) -> Goomba:
	return preload("res://entities/enemies/goomba/goomba.tscn").instantiate()


func _ready() -> void:
	Utils.create_sync_timer(self, _on_state_sync_timer)
	$AnimatedSprite2D.play("walk")


func _process(_delta) -> void:
	if (!alive && is_multiplayer_authority()):
		death_timer -= _delta
		if (death_timer < 0.0):
			queue_free()


func _physics_process(delta: float) -> void:
	if (!is_on_floor()):
		velocity += get_gravity() * delta

	if (!alive):
		velocity.x = 0.0
		move_and_slide()
		return

	if (is_on_wall()):
		direction = -direction

	velocity.x = lerp(velocity.x, direction * MAX_SPEED, min(delta * 4, 1))
	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if (alive && player && (player.velocity.y > 0)):
		player.velocity.y = -256.0
		if (body.is_multiplayer_authority()):
			player.sync_kinematics(player.position, player.velocity)
			sync_alive.rpc(false)


func _on_state_sync_timer() -> void:
	if (is_multiplayer_authority()):
		sync_kinematics.rpc(position, velocity, direction)


@rpc("any_peer", "call_local", "reliable")
func sync_alive(_alive: bool):
	self.alive = _alive
	if (!alive):
		$AnimatedSprite2D.play("die")


@rpc("unreliable_ordered")
func sync_kinematics(_position: Vector2, _velocity: Vector2, _direction: int):
	position = _position
	velocity = _velocity
	direction = _direction
