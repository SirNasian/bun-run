class_name Game extends Node2D


const SYNC_TIME: float = 0.2

@onready var config: Configuration = Configuration.load()
var players: Dictionary = {}
var goomba_spawn_timer: float = 0.0


func _ready() -> void:
	print("configuration paths: %s" % Configuration.get_paths())
	print("configuration loaded: %s" % config._config)

	var config_issues = Configuration.validate(config)
	if (config_issues):
		push_error("configuration validation failed: %s" % config_issues)
		get_tree().quit()
		return

	Configuration.save(config)

	$World/PlayerSpawner.spawn_function = Player.instantiate
	$World/GoombaSpawner.spawn_function = Goomba.instantiate

	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.connected_to_server.connect(_server_connected)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

	if (config.is_server()):
		host_server(config.get_server_bind_address(), config.get_server_port())
	else:
		connect_server(config.get_client_server_address(), config.get_client_port())


func _process(delta: float):
	if (is_multiplayer_authority()):
		goomba_spawn_timer -= delta
		if (goomba_spawn_timer < 0.0):
			goomba_spawn_timer = 3.0
			$World/GoombaSpawner.spawn({})


func _connection_failed() -> void:
	print("failed to connect to server")


func _server_connected() -> void:
	print("connected to server")


func _server_disconnected() -> void:
	print("disconnected from server")


func _peer_connected(id: int) -> void:
	print("player connected (%d)" % id)
	if (is_multiplayer_authority()):
		players[id] = $World/PlayerSpawner.spawn(id)


func _peer_disconnected(id: int) -> void:
	print("player disconnected (%d)" % id)
	if (is_multiplayer_authority()):
		players[id].queue_free()
		players.erase(id)

func host_server(address: String, port: int) -> void:
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

	if (!OS.has_feature("dedicated_server")):
		$World/PlayerSpawner.spawn(get_multiplayer_authority())

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
