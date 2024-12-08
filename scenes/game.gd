extends Node2D


func _ready() -> void:
	var config = Configuration.load("config.json")

	var peer = ENetMultiplayerPeer.new()
	if (config.role == Configuration.ROLE_SERVER):
		peer.create_server(config.port, config.max_clients)
	else:
		peer.create_client(config.address, config.port)

	self.multiplayer.server_disconnected.connect(_server_disconnected)
	self.multiplayer.peer_connected.connect(_peer_connected)
	self.multiplayer.peer_disconnected.connect(_peer_disconnected)
	self.multiplayer.multiplayer_peer = peer

	$PlayerSpawner.spawn_function = Player.instantiate
	if (self.multiplayer.is_server()):
		$PlayerSpawner.spawn(self.get_multiplayer_authority())


func _server_disconnected() -> void:
	print("server disconnect")


func _peer_connected(id: int) -> void:
	if (self.is_multiplayer_authority()):
		$PlayerSpawner.spawn(id)


func _peer_disconnected(id: int) -> void:
	if (self.is_multiplayer_authority()):
		for player: Player in $Players.get_children():
			if (player.get_multiplayer_authority() == id):
				player.queue_free()
				break
