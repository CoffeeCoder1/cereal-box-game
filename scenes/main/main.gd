extends Node

@onready var multiplayer_lobby: MultiplayerLobby = $MultiplayerLobby
@onready var menu: Control = $Menu
@onready var game: Node = $Game


func _on_menu_create_server() -> void:
	multiplayer_lobby.create_game()
	menu.hide()
	await multiplayer.peer_connected
	game.start_game.rpc()


func _on_menu_join_server(ip: String) -> void:
	multiplayer_lobby.join_game(ip)
	menu.hide()


func _on_multiplayer_lobby_server_disconnected() -> void:
	menu.show()
