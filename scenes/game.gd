extends Node2D

@onready var config = Configuration.load()
var players = {}


func _ready() -> void:
	print("configuration paths: %s" % Configuration.get_paths())
	print("configuration loaded: %s" % config._config)

	var config_issues = Configuration.validate(self.config)
	if (config_issues):
		push_error("configuration validation failed: %s" % config_issues)
		self.get_tree().quit()
		return

	Configuration.save(config)

	$World/PlayerSpawner.spawn_function = Player.instantiate
	$World/GoombaSpawner.spawn_function = Goomba.instantiate

	self.multiplayer.connection_failed.connect(_connection_failed)
	self.multiplayer.connected_to_server.connect(_server_connected)
	self.multiplayer.server_disconnected.connect(_server_disconnected)
	self.multiplayer.peer_connected.connect(_peer_connected)
	self.multiplayer.peer_disconnected.connect(_peer_disconnected)

	if (config.is_server()):
		self.host_server(config.get_server_bind_address(), config.get_server_port())
		for i in range(1, 8):
			$World/GoombaSpawner.spawn({}).position.x += i * 32
	else:
		self.connect_server(config.get_client_server_address(), config.get_client_port())


func _connection_failed() -> void:
	print("failed to connect to server")


func _server_connected() -> void:
	print("connected to server")


func _server_disconnected() -> void:
	print("disconnected from server")


func _peer_connected(id: int) -> void:
	print("player connected (%d)" % id)
	if (self.is_multiplayer_authority()):
		self.players[id] = $World/PlayerSpawner.spawn(id)


func _peer_disconnected(id: int) -> void:
	print("player disconnected (%d)" % id)
	if (self.is_multiplayer_authority()):
		self.players[id].queue_free()
		self.players.erase(id)

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
	self.multiplayer.multiplayer_peer = peer

	if (!OS.has_feature("dedicated_server")):
		$World/PlayerSpawner.spawn(self.get_multiplayer_authority())

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
	self.multiplayer.multiplayer_peer = peer

	print("connecting: %s" % { "address": address, "port": port, "tls": !!tls_options })
