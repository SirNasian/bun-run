class_name ConnectionMenu extends PanelContainer


signal host_server(address: String, port: int)
signal connect_server(address: String, port: int)


func _ready() -> void:
	var host_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/HostButton
	var connect_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/ConnectButton
	host_button.visible = !OS.has_feature("web")
	host_button.pressed.connect(self._host_pressed)
	connect_button.pressed.connect(self._connect_pressed)


func _host_pressed() -> void:
	var connection = self.get_connection_details()
	self.host_server.emit(connection.address, connection.port)


func _connect_pressed() -> void:
	var connection = self.get_connection_details()
	self.connect_server.emit(connection.address, connection.port)


func get_connection_details() -> Dictionary:
	var address_input: LineEdit = $MarginContainer/VBoxContainer/AddressInput
	var tokens = address_input.text.split(":")
	return {
		"address": str(tokens[0]),
		"port": int(tokens[1]) if tokens.size() > 1 else 8000,
	}
