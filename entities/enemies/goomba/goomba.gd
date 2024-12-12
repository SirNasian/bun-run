class_name Goomba extends CharacterBody2D


const MAX_SPEED: float = 128.0

static var ID: int = 0

var id: int = 0
var alive: bool = true
var death_timer: float = 1.0
var direction: int = 1


static func instantiate() -> Goomba:
	var goomba = preload("res://entities/enemies/goomba/goomba.tscn").instantiate()
	ID += 1
	goomba.id = ID
	goomba.name = "Goomba-%d" % ID
	return goomba


func serialize() -> Array:
	return [
		id,
		position,
		velocity,
		direction,
		alive,
	]


func deserialize(data: Array) -> Goomba:
	id = data[0]
	name = "Goomba-%d" % data[0]
	position = data[1]
	velocity = data[2]
	direction = data[3]
	alive = data[4]
	return self


func _ready() -> void:
	Game.instance.sync.connect(_on_sync)
	$AnimatedSprite2D.play("walk")


func _process(_delta) -> void:
	if (!alive):
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
		if (player.is_multiplayer_authority()):
			player.sync_kinematics(player.position, player.velocity)
			sync_alive.rpc(false)


func _on_sync() -> void:
	if (is_multiplayer_authority() && alive):
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
