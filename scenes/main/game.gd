extends Node

const MAZE = preload("res://scenes/games/maze/maze.tscn")

@export var multiplayer_lobby: MultiplayerLobby

var level: Node


func create_game() -> void:
	pass


@rpc('authority', 'call_local', 'reliable')
func start_game() -> void:
	level = MAZE.instantiate()
	add_child(level)
	# TODO: Handle players joining after game start
	level.start_game(multiplayer_lobby.get_players())
