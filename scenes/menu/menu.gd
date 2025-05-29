extends Control

signal create_server
signal join_server(ip: String)

@onready var main_menu: Window = $MainMenu
@onready var join_server_menu: Window = $JoinServerMenu
@onready var ip_address_join_edit: LineEdit = $JoinServerMenu/PanelContainer/MarginContainer/MarginContainer/GridContainer/IPAddressJoinEdit


func _on_create_server_button_pressed() -> void:
	create_server.emit()
	main_menu.hide()


func _on_join_server_button_pressed() -> void:
	join_server_menu.show()


func _on_join_server_window_join_button_pressed() -> void:
	join_server.emit(ip_address_join_edit.text)
	main_menu.hide()
	join_server_menu.hide()
