class_name Configuration extends Object

const CONFIG_SCHEMA = {
	"role": TYPE_STRING,
	"server": {
		"bind_address": TYPE_STRING,
		"port": TYPE_FLOAT,
		"certificate_path": TYPE_STRING,
		"certificate_key_path": TYPE_STRING,
	},
	"client": {
		"server_address": TYPE_STRING,
		"port": TYPE_FLOAT,
		"certificate_path": TYPE_STRING,
	},
}

static var LOCAL_CONFIG_PATH = "user://config.json" if (OS.has_feature("web")) else "./config.json"
var _config: Dictionary = {}


static func load() -> Configuration:
	var load_json = func (file_path: String) -> Dictionary:
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text()) if (file) else {}
		if (file): file.close()
		return json

	var config = Configuration.new()
	config._config.merge(load_json.call(LOCAL_CONFIG_PATH))
	config._config.merge(load_json.call("res://config.json"))
	return config


static func save(config: Configuration) -> void:
	var file = FileAccess.open(LOCAL_CONFIG_PATH, FileAccess.WRITE)
	file.store_line(JSON.stringify(config._config, "\t", false))
	file.close()


static func validate(config: Configuration) -> Dictionary:
	return Utils.validate_dictionary(config._config, CONFIG_SCHEMA, "config")


func is_server() -> bool:
	return _config.get("role") == "server" && !OS.has_feature("web")


func get_server_bind_address() -> String:
	return _config.get("server").get("bind_address")


func get_server_port() -> int:
	return int(_config.get("server").get("port"))


func get_server_certificate_path() -> String:
	return _config.get("server").get("certificate_path")


func get_server_certificate_key_path() -> String:
	return _config.get("server").get("certificate_key_path")


func get_client_server_address() -> String:
	return _config.get("client").get("server_address")


func get_client_port() -> int:
	return int(_config.get("client").get("port"))


func get_client_certificate_path() -> String:
	return _config.get("client").get("certificate_path")
