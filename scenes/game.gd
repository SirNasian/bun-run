extends Node2D


var config = Configuration.load("config.json")
var peer: ENetMultiplayerPeer


func _ready() -> void:

	self.peer = ENetMultiplayerPeer.new()
	if (config.role == Configuration.ROLE_SERVER):
		peer.create_server(config.port, config.max_clients)
	else:
		peer.create_client(config.address, config.port)

	self.multiplayer.connection_failed.connect(quit)
	self.multiplayer.server_disconnected.connect(quit)
	self.multiplayer.peer_connected.connect(_peer_connected)
	self.multiplayer.peer_disconnected.connect(_peer_disconnected)
	self.multiplayer.multiplayer_peer = peer

	$PlayerSpawner.spawn_function = Player.instantiate
	if (self.multiplayer.is_server()):
		$PlayerSpawner.spawn(self.get_multiplayer_authority())


func quit() -> void:
	self.get_tree().quit()


func _peer_connected(id: int) -> void:
	if (self.is_multiplayer_authority()):
		$PlayerSpawner.spawn(id)


func _peer_disconnected(id: int) -> void:
	if (self.is_multiplayer_authority()):
		for player: Player in $Players.get_children():
			if (player.get_multiplayer_authority() == id):
				player.queue_free()
				break
