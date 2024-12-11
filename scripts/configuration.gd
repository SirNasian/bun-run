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

static var CONFIG_PATH = "./config.json"
var _config: Dictionary = {}


static func load() -> Configuration:
	var load_json = func (file_path: String) -> Dictionary:
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text()) if (file) else {}
		if (file): file.close()
		return json

	var config = Configuration.new()
	Utils.recursive_merge(config._config, load_json.call(CONFIG_PATH))
	Utils.recursive_merge(config._config, load_json.call("user://config.json"))
	Utils.recursive_merge(config._config, load_json.call("res://config.json"))
	return config


static func save(config: Configuration) -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if (file):
		file.store_line(JSON.stringify(config._config, "\t", false))
		file.close()


static func validate(config: Configuration) -> Dictionary:
	return Utils.validate_dictionary(config._config, CONFIG_SCHEMA, "config")


static func get_paths() -> Dictionary:
	var paths = {}
	for path in [CONFIG_PATH, "user://config.json"]:
		path = ProjectSettings.globalize_path(path)
		paths[path] = ResourceLoader.exists(path)
	return paths


func is_server() -> bool:
	return OS.has_feature("dedicated_server") || ((_config.get("role") == "server") && !OS.has_feature("web"))


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
