extends Node

const MAZE = preload("res://scenes/games/maze/maze.tscn")

@export var multiplayer_lobby: MultiplayerLobby

var level: Node


func create_game() -> void:
	pass


func start_game() -> void:
	_setup_level.rpc()
	# TODO: Handle players joining after game start
	level.start_game()


@rpc('authority', 'call_local', 'reliable')
func _setup_level() -> void:
	level = MAZE.instantiate()
	add_child(level)
	level.multiplayer_lobby = multiplayer_lobby
