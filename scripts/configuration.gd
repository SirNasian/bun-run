class_name Configuration extends Node

const ROLE_CLIENT = "client"
const ROLE_SERVER = "server"

var role: String = Configuration.ROLE_SERVER
var address: String = "localhost"
var port: int = 8000
var max_clients: int = 32

static func load(file_path: String) -> Configuration:
	var config = Configuration.new()
	var file = FileAccess.open(file_path, FileAccess.READ)
	var dict = JSON.parse_string(file.get_as_text()) if (file) else {}
	if (dict):
		if (dict.has("role")): config.role = dict.role
		if (dict.has("address")): config.address = dict.address
		if (dict.has("port")): config.port = dict.port
		if (dict.has("max_clients")): config.max_clients = dict.max_clients
	return config
