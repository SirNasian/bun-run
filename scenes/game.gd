extends Node2D

var config = Configuration.load()


func _ready() -> void:
	if (OS.has_feature("debug")): print_debug("config: %s" % self.config)
	$PlayerSpawner.spawn_function = Player.instantiate

	self.multiplayer.connection_failed.connect(_quit)
	self.multiplayer.server_disconnected.connect(_quit)
	self.multiplayer.peer_connected.connect(_peer_connected)
	self.multiplayer.peer_disconnected.connect(_peer_disconnected)

	var connection_menu: ConnectionMenu = $CanvasLayer/CenterContainer/ConnectionMenu
	connection_menu.host_server.connect(_host_server)
	connection_menu.connect_server.connect(_connect_server)

	if ((Configuration.file_exists() && self.config.address) || OS.has_feature("dedicated_server")):
		if (self.config.is_server):
			self._host_server(self.config.address, self.config.port)
		else:
			self._connect_server(self.config.address, self.config.port)


func _host_server(address: String, port: int) -> void:
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var use_ssl = config.use_ssl && ResourceLoader.exists("res://private.key") && ResourceLoader.exists("res://certificate.crt")
	var tls_opt = TLSOptions.server(load("res://private.key"), load("res://certificate.crt")) if use_ssl else null
	address = address if address else "*"
	peer.create_server(port, address, tls_opt)
	self.multiplayer.multiplayer_peer = peer
	self.hide_connection_menu()
	if (!OS.has_feature("dedicated_server")):
		$PlayerSpawner.spawn(self.get_multiplayer_authority())
	if (OS.has_feature("debug")): print_debug("host: %s" % { "address": address, "port": port, "use_ssl": use_ssl })


func _connect_server(address: String, port: int) -> void:
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var protocol = "wss" if (config.use_ssl) else "ws"
	var use_cert = config.use_ssl && ResourceLoader.exists("res://certificate.crt")
	var tls_opt = TLSOptions.client(load("res://certificate.crt")) if (use_cert) else null
	address = address if address else "localhost"
	peer.create_client("%s://%s:%d" % [protocol, address, port], tls_opt)
	self.multiplayer.multiplayer_peer = peer
	self.hide_connection_menu()
	if (OS.has_feature("debug")): print_debug("connect: %s" % { "protocol": protocol, "address": address, "port": port, "use_cert": use_cert })


func hide_connection_menu() -> void:
	var connection_menu: ConnectionMenu = $CanvasLayer/CenterContainer/ConnectionMenu
	connection_menu.visible = false


func _quit() -> void:
	self.get_tree().quit()


func _peer_connected(id: int) -> void:
	if (self.is_multiplayer_authority()):
		$PlayerSpawner.spawn(id)


func _peer_disconnected(id: int) -> void:
	if (self.is_multiplayer_authority()):
		for player: Player in $World/Players.get_children():
			if (player.get_multiplayer_authority() == id):
				player.queue_free()
				break
