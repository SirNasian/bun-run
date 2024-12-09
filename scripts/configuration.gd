class_name Configuration extends Node


static func load() -> Dictionary:
	var file = FileAccess.open("res://config.json", FileAccess.READ)
	var dict = JSON.parse_string(file.get_as_text()) if (file) else {}
	return {
		"is_server": (dict.has("role") && dict.role == "server") || OS.has_feature("dedicated_server"),
		"address": dict.address if dict.has("address") else "",
		"port": int(dict.port) if dict.has("port") else 8000,
		"use_ssl": dict.use_ssl if dict.has("use_ssl") else OS.has_feature("web"),
	}


static func file_exists() -> bool:
	return ResourceLoader.exists("res://config.json")
