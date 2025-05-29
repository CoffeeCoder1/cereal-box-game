class_name Player extends Node

## The player's current state.
@export var state: PlayerState = PlayerState.LOADING

signal state_changed(state: PlayerState)

var _character_node: Node

enum PlayerState {
	LOADING,
	READY,
	PLAYING
}


func set_character_node(character_node: Node) -> void:
	_character_node = character_node
	character_node.name = "Player" + str(get_multiplayer_authority())
	character_node.set_multiplayer_authority(get_multiplayer_authority())


func get_character_node() -> Node:
	return _character_node


func set_state(new_state: PlayerState) -> void:
	_set_state.rpc(new_state)


@rpc("authority", "call_local", "reliable")
func _set_state(new_state: PlayerState) -> void:
	state = new_state
	
	state_changed.emit(state)
