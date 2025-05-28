class_name Player extends Node

## The player's multiplayer ID.
@export var id: int
## The player's current state.
@export var state: PlayerState

enum PlayerState {
	LOADING,
	READY,
	PLAYING
}
