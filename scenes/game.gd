extends Node2D

@onready var config = Configuration.load()


func _ready() -> void:
	print("configuration paths: %s" % Configuration.get_paths())
	print("configuration loaded: %s" % config._config)

	var config_issues = Configuration.validate(self.config)
	if (config_issues):
		push_error("configuration validation failed: %s" % config_issues)
		self.get_tree().quit()
		return

	Configuration.save(config)

	$PlayerSpawner.spawn_function = Player.instantiate

	self.multiplayer.connection_failed.connect(_quit)
	self.multiplayer.server_disconnected.connect(_quit)
	self.multiplayer.peer_connected.connect(_peer_connected)
	self.multiplayer.peer_disconnected.connect(_peer_disconnected)

	if (config.is_server()):
		self._host_server(config.get_server_bind_address(), config.get_server_port())
	else:
		self._connect_server(config.get_client_server_address(), config.get_client_port())


func _exit_tree() -> void:
	config.free()


func _host_server(address: String, port: int) -> void:
	var tls = _get_server_tls("res://private.key", "res://certificate.crt")
	if (!tls): tls = _get_server_tls(config.get_server_certificate_key_path(), config.get_server_certificate_path())
	address = address if address else config.get_server_bind_address()
	port = port if port else config.get_server_port()

	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_server(port, address, tls)
	self.multiplayer.multiplayer_peer = peer

	if (!OS.has_feature("dedicated_server")):
		$PlayerSpawner.spawn(self.get_multiplayer_authority())

	print("hosting: %s" % { "address": address, "port": port, "tls": !!tls })


func _get_server_tls(key_path: String, cert_path: String) -> TLSOptions:
	var exists = ResourceLoader.exists(key_path) && ResourceLoader.exists(cert_path)
	return TLSOptions.server(load(key_path), load(cert_path)) if (exists) else null


func _connect_server(address: String, port: int) -> void:
	var tls = _get_client_tls("res://certificate.crt")
	if (!tls): tls = _get_client_tls(config.get_server_certificate_path())
	var protocol = "wss" if (tls) else "ws"
	address = address if address else config.get_client_server_address()
	port = port if port else config.get_client_port()

	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_client("%s://%s:%d" % [protocol, address, port], tls)
	self.multiplayer.multiplayer_peer = peer

	print("connecting: %s" % { "address": address, "port": port, "tls": !!tls })


func _get_client_tls(cert_path: String) -> TLSOptions:
	var exists = ResourceLoader.exists(cert_path)
	return TLSOptions.client(load(cert_path)) if (exists) else null


func hide_connection_menu() -> void:
	var connection_menu: ConnectionMenu = $CanvasLayer/CenterContainer/ConnectionMenu
	connection_menu.visible = false


func _quit() -> void:
	self.get_tree().quit()


func _peer_connected(id: int) -> void:
	print("player connected (%d)" % id)
	if (self.is_multiplayer_authority()):
		$PlayerSpawner.spawn(id)


func _peer_disconnected(id: int) -> void:
	print("player disconnected (%d)" % id)
	if (self.is_multiplayer_authority()):
		for player: Player in $World/Players.get_children():
			if (player.get_multiplayer_authority() == id):
				player.queue_free()
				break
