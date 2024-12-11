class_name DeveloperWorld extends Node2D


var loaded: bool = false
var players: Dictionary = {}
var goomba_spawn_timer: float = 0.0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	if (is_multiplayer_authority()):
		if (!OS.has_feature("dedicated_server")):
			spawn_player(".", multiplayer.get_unique_id())
			spawn_player.rpc(".", multiplayer.get_unique_id())
	else:
		_on_client_load_world.rpc_id(get_multiplayer_authority(), multiplayer.get_unique_id())


func _process(delta: float):
	if (is_multiplayer_authority()):
		goomba_spawn_timer -= delta
		if (goomba_spawn_timer < 0.0):
			goomba_spawn_timer = 3.0
			spawn_goomba.rpc(".", spawn_goomba(".").name)


@rpc("any_peer")
func _on_client_load_world(id: int) -> void:
	_on_peer_connected(id)


func _on_peer_connected(id: int) -> void:
	if (is_multiplayer_authority()):
		var nodes = get_children()
		while (!nodes.is_empty()):
			var node = nodes.pop_back()
			if (node is Goomba): spawn_goomba.rpc_id(id, get_path_to(node.get_parent()), node.name)
			if (node is Player): spawn_player.rpc_id(id, get_path_to(node.get_parent()), node.get_multiplayer_authority())
			nodes.append_array(node.get_children())
		spawn_player(".", id)
		spawn_player.rpc(".", id)


func _on_peer_disconnected(id: int) -> void:
	players[id].queue_free()
	players.erase(id)


@rpc
func spawn_player(_path: String, _id: int) -> Player:
	var player = Player.instantiate(_id)
	get_node(_path).add_child(player, true)
	players[_id] = player
	return player

@rpc
func spawn_goomba(_path: String, _name: String = "") -> Goomba:
	var goomba = Goomba.instantiate()
	if (_name): goomba.name = _name
	get_node(_path).add_child(goomba, true)
	return goomba
