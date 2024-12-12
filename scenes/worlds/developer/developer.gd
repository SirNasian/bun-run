class_name DeveloperWorld extends Node2D


enum ENTITY {
	PLAYER,
	GOOMBA,
}

var players: Dictionary = {}
var goomba_spawn_timer: float = 1.0


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if (is_multiplayer_authority()):
		if (!OS.has_feature("dedicated_server")):
			var player = Player.instantiate()
			player.set_multiplayer_authority(get_multiplayer_authority())
			add_child(player, true)
			spawn.rpc(get_path(), player.serialize() + [ENTITY.PLAYER])
	else:
		_on_client_world_load.rpc_id(get_multiplayer_authority(), multiplayer.get_unique_id())


func _process(delta: float):
	if (is_multiplayer_authority()):
		goomba_spawn_timer -= delta
		if (goomba_spawn_timer < 0.0):
			goomba_spawn_timer = 3.0
			var goomba = Goomba.instantiate()
			add_child(goomba, true)
			spawn.rpc(get_path(), goomba.serialize() + [ENTITY.GOOMBA])


@rpc("any_peer")
func _on_client_world_load(id: int) -> void:
	if (is_multiplayer_authority()):
		var nodes = get_children()
		while (!nodes.is_empty()):
			var node = nodes.pop_back()
			if (node is Player): spawn.rpc_id(id, node.get_parent().get_path(), node.serialize() + [ENTITY.PLAYER])
			if (node is Goomba): spawn.rpc_id(id, node.get_parent().get_path(), node.serialize() + [ENTITY.GOOMBA])
			nodes.append_array(node.get_children())
		players[id] = Player.instantiate()
		players[id].set_multiplayer_authority(id)
		add_child(players[id], true)
		spawn.rpc(get_path(), players[id].serialize() + [ENTITY.PLAYER])


func _on_peer_disconnected(id: int) -> void:
	players[id].queue_free()
	players.erase(id)


@rpc
func spawn(path: String, data: Array) -> Node2D:
	var node
	match (data.back()):
		ENTITY.PLAYER: node = Player.instantiate()
		ENTITY.GOOMBA: node = Goomba.instantiate()
	if (data.size()): node.deserialize(data)
	get_node(path).add_child(node)
	return node
