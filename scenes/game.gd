extends Node2D

func _ready() -> void:
	var player = Player.instantiate()
	self.add_child(player)

	var camera: Camera2D = Camera2D.new()
	camera.zoom = Vector2(1.5, 1.5)
	camera.position_smoothing_enabled = true
	player.add_child(camera)
