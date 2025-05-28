extends Node

const MAZE = preload("res://scenes/games/maze/maze.tscn")

var level: Node


func create_game() -> void:
	pass


func start_game() -> void:
	level = MAZE.instantiate()
	add_child(level)
