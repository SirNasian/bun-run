extends Node2D


enum ENTITY {
	PLAYER,
	GOOMBA,
}

var players: Dictionary = {}


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if (is_multiplayer_authority()):
		if (!OS.has_feature("dedicated_server")):
			var player = create_player(get_multiplayer_authority())
			spawn.rpc(get_path(), player.serialize() + [ENTITY.PLAYER])
			set_camera_limits.rpc(player.get_node("Camera2D").get_path())
	else:
		_on_client_world_load.rpc_id(get_multiplayer_authority(), multiplayer.get_unique_id())


@rpc("any_peer")
func _on_client_world_load(id: int) -> void:
	if (is_multiplayer_authority()):
		var nodes = get_children()
		while (!nodes.is_empty()):
			var node = nodes.pop_back()
			if (node is Player): spawn.rpc_id(id, node.get_parent().get_path(), node.serialize() + [ENTITY.PLAYER])
			if (node is Goomba): spawn.rpc_id(id, node.get_parent().get_path(), node.serialize() + [ENTITY.GOOMBA])
			nodes.append_array(node.get_children())
		players[id] = create_player(id)
		spawn.rpc(get_path(), players[id].serialize() + [ENTITY.PLAYER])
		set_camera_limits.rpc(players[id].get_node("Camera2D").get_path())


func _on_peer_disconnected(id: int) -> void:
	if (players.has(id)):
		players[id].queue_free()
		players.erase(id)


func create_player(authority: int) -> Player:
	var player = Player.instantiate()
	player.set_multiplayer_authority(authority)
	player.position = $PlayerSpawn.position
	player.jump_force = 448.0
	add_child(player, true)
	return player


@rpc("call_local")
func set_camera_limits(path: String) -> void:
	var camera = get_node(path) as Camera2D
	camera.limit_top = -180
	camera.limit_bottom = 180
	camera.limit_left = -2532
	camera.limit_right = 2532


@rpc
func spawn(path: String, data: Array) -> Node2D:
	var node
	match (data.back()):
		ENTITY.PLAYER: node = Player.instantiate()
		ENTITY.GOOMBA: node = Goomba.instantiate()
	if (data.size()): node.deserialize(data)
	get_node(path).add_child(node)
	return node
