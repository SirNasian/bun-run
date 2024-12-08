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

	if (self.multiplayer.is_server()):
		self.add_players([self.multiplayer.get_unique_id()])


func _peer_connected(id: int) -> void:
	if (self.multiplayer.is_server()):
		self.add_players.rpc_id(id, player_ids)
		self.add_players.rpc([id])


@rpc("call_local")
func add_players(ids: Array) -> void:
	for id: int in ids:
		var player = Player.instantiate(id)
		player.get_node("Camera2D").enabled = (id == self.multiplayer.get_unique_id())
		self.player_ids.push_back(player.multiplayer_id)
		$Players.add_child(player)
