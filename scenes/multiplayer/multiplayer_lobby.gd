class_name MultiplayerLobby extends Node

const PLAYER_NAME_FORMAT = "Player{0}"

## The default server IP to connect to.
@export var default_server_ip: String = "127.0.0.1"
## The port to bind the TCP server to.
@export var port: int = 7000
## The maximum number of clients that can connect to the server.
@export var max_connections: int = 20
## The node to use to store player nodes.
@export var player_container: Node

var _peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

## Emitted when a connection to the server is successfully made.
signal connected_to_server
## Emitted when disconnected from the server.
signal server_disconnected
## Emitted when the connection failed.
signal connection_failed


func _ready():
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Connect to a server.
func join_game(address: String = ""):
	if address.is_empty():
		address = default_server_ip
	var error = _peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = _peer


## Create a server.
func create_game():
	var error = _peer.create_server(port, max_connections)
	if error:
		return error
	
	# Set up signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	multiplayer.multiplayer_peer = _peer
	
	# Create a player for ourselves
	add_player(multiplayer.get_unique_id())


func leave_game():
	multiplayer.multiplayer_peer.close()


func _on_connected_ok():
	connected_to_server.emit()


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()


func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		add_player(id)
		add_player.rpc(id)
		
		var host_id: int = multiplayer.get_unique_id()
		
		var peer_list := multiplayer.get_peers()
		peer_list.append(host_id)
		
		for existing in peer_list:
			if existing != id:
				add_player.rpc_id(id, existing)


func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		remove_player(id)
		remove_player.rpc(id)


## Creates a player for the given ID.
@rpc("any_peer")
func add_player(id: int) -> void:
	var player = Player.new()
	player.name = PLAYER_NAME_FORMAT.format([id])
	player.set_multiplayer_authority(id)
	player_container.add_child(player)


@rpc("any_peer")
func remove_player(id: int) -> void:
	var player := player_container.get_node_or_null(PLAYER_NAME_FORMAT.format([id]))
	
	if is_instance_valid(player):
		player.queue_free()


## Gets all the players.
func get_players() -> Array[Player]:
	var player_array: Array[Player]
	for player in player_container.get_children():
		player_array.append(player as Player)
	return player_array


## Gets a player by ID.
func get_player(id: int) -> Player:
	return player_container.get_node(PLAYER_NAME_FORMAT.format([id])) as Player
