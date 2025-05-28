extends Control

signal create_server
signal join_server(ip: String)


func _on_create_server_button_pressed() -> void:
	create_server.emit()


func _on_join_server_button_pressed() -> void:
	join_server.emit("127.0.0.1")
