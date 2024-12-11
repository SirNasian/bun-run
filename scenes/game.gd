class_name Game extends Node2D


const SYNC_TIME: float = 0.2

@onready var config: Configuration = Configuration.load()
var heartbeats: Dictionary = {}
var heartbeat_timer: Timer = null
var world_path: String = "res://scenes/worlds/developer/developer.tscn"
var world: Node2D = null


func _ready() -> void:
	print("configuration paths: %s" % Configuration.get_paths())
	print("configuration loaded: %s" % config._config)

	var config_issues = Configuration.validate(config)
	if (config_issues):
		push_error("configuration validation failed: %s" % config_issues)
		get_tree().quit()
		return

	Configuration.save(config)

	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.connected_to_server.connect(_server_connected)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	if (config.is_server()):
		host_server(config.get_server_bind_address(), config.get_server_port())
	else:
		connect_server(config.get_client_server_address(), config.get_client_port())


func _input(event: InputEvent) -> void:
	if (is_multiplayer_authority() && (event is InputEventKey) && event.is_pressed()):
		if ((event as InputEventKey).keycode == 4194308):
			sync_world.rpc(world_path, sync_world(world_path).name)


func _connection_failed() -> void:
	print("failed to connect to server")


func _server_connected() -> void:
	heartbeat_timer = Utils.create_sync_timer(self, _on_heartbeat_sync_timer)
	print("connected to server")


func _server_disconnected() -> void:
	heartbeat_timer.queue_free()
	print("disconnected from server")


func _on_peer_connected(id: int) -> void:
	print("peer connected (%d)" % id)
	if (is_multiplayer_authority()):
		sync_world.rpc_id(id, world_path, world.name)
		heartbeats[id] = Time.get_ticks_msec()


func _on_peer_disconnected(id: int) -> void:
	print("peer disconnected (%d)" % id)


func _on_heartbeat_sync_timer() -> void:
	if (is_multiplayer_authority()):
		for id in multiplayer.get_peers():
			if ((id > 1) && ((Time.get_ticks_msec() - heartbeats[id]) > (SYNC_TIME * 1000 * 10))):
				multiplayer.multiplayer_peer.disconnect_peer(id)
	else:
		sync_heartbeat.rpc_id(1, multiplayer.get_unique_id())


@rpc("any_peer", "unreliable_ordered")
func sync_heartbeat(id: int) -> void:
	if (is_multiplayer_authority()):
		heartbeats[id] = Time.get_ticks_msec()


@rpc("reliable")
func sync_world(_world_path: String, _name: String = "") -> Node2D:
	if (world): world.queue_free()
	world = load(_world_path).instantiate()
	if (_name): world.name = _name
	add_child(world, true)
	return world


func host_server(address: String, port: int, _world_path: String = world_path) -> void:
	var get_tls = func (paths: Array) -> TLSOptions:
		for p in paths:
			if (ResourceLoader.exists(p[0]) && ResourceLoader.exists(p[1])):
				var tls = TLSOptions.server(load(p[0]), load(p[1]))
				if (tls): return tls
		return null

	var tls_options = get_tls.call([
		[config.get_server_certificate_key_path(), config.get_server_certificate_path()],
		["res://private.key", "res://certificate.crt"],
	])

	address = address if address else config.get_server_bind_address()
	port = port if port else config.get_server_port()

	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_server(port, address, tls_options)
	multiplayer.multiplayer_peer = peer

	heartbeat_timer = Utils.create_sync_timer(self, _on_heartbeat_sync_timer)
	sync_world(_world_path)
	print("hosting: %s" % { "address": address, "port": port, "tls": !!tls_options })


func connect_server(address: String, port: int) -> void:
	var get_tls = func (paths: Array) -> TLSOptions:
		for p in paths:
			if (ResourceLoader.exists(p)):
				var tls = TLSOptions.client(load(p))
				if (tls): return tls
		return null

	var tls_options = get_tls.call([
		config.get_client_certificate_path(),
		"res://certificate.crt",
	])

	var protocol = "wss" if (tls_options) else "ws"
	address = address if address else config.get_client_server_address()
	port = port if port else config.get_client_port()

	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_client("%s://%s:%d" % [protocol, address, port], tls_options)
	multiplayer.multiplayer_peer = peer

	print("connecting: %s" % { "address": address, "port": port, "tls": !!tls_options })
