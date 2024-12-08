extends Node2D


var player_ids = []


func _ready() -> void:
	var config = Configuration.load("config.json")

	var peer = ENetMultiplayerPeer.new()
	if (config.role == Configuration.ROLE_SERVER):
		peer.create_server(config.port, config.max_clients)
	else:
		peer.create_client(config.address, config.port)

	self.multiplayer.peer_connected.connect(_peer_connected)
	self.multiplayer.multiplayer_peer = peer

	self.add_player(self.multiplayer.get_unique_id())


func _peer_connected(id: int) -> void:
	self.add_player(id)


func add_player(id: int) -> void:
	var player = Player.instantiate(id)
	$Players.add_child(player)
	player.name = str("player-", id)
	player.get_node("Camera2D").enabled = player.is_multiplayer_authority()
