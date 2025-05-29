extends Node2D

const PLAYER = preload("res://scenes/games/maze/maze_player/maze_player.tscn")

@export var multiplayer_lobby: MultiplayerLobby
@export var floor_rotation: float

signal floor_rotation_changed(new_rotation: float)

@onready var pivot: Node2D = $Pivot
@onready var player_container: Node = $Players
@onready var spawn_point_1: Marker2D = $Pivot/SpawnPoint1
@onready var spawn_point_2: Marker2D = $Pivot/SpawnPoint2

var _spawn_point_average: float
## Enables the rotation effect. Should be disabled until players are set up so
## the level doesn't rotate erratically.
var _enable_rotation: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority() and _enable_rotation:
		# Figure out how much to rotate the level
		var position_average: float
		for player in player_container.get_children():
			player = player as MazePlayer
			if is_instance_valid(player):
				position_average += player.global_position.x
		position_average /= player_container.get_child_count()
		
		pivot.rotation = lerp(pivot.rotation, (position_average - _spawn_point_average) / 200, delta * 10)
		
		# Find what the floor is (closest wall to being horizontal)
		floor_rotation = pivot.rotation + PI / 4
		if floor_rotation < 0:
			floor_rotation += 2 * PI
		
		if (floor_rotation >= 0 and floor_rotation < PI / 2):
			floor_rotation -= PI / 4
		elif (floor_rotation >= PI / 2 and floor_rotation < PI):
			floor_rotation += 5 * PI / 4
		elif (floor_rotation >= PI and floor_rotation < (3 * PI / 2)):
			floor_rotation += 3 * PI / 4
		else:
			floor_rotation += PI / 4
	
	floor_rotation_changed.emit(floor_rotation)


## Sets up the game on all the clients. Should be called on the server.
func start_game() -> void:
	var spawn_points: Array[float]
	
	# Create the players
	for player in multiplayer_lobby.get_players():
		var spawn_point := spawn_point_1.global_transform if player_container.get_child_count() % 2 == 1 else spawn_point_2.global_transform
		_add_player.rpc(player.get_multiplayer_authority(), spawn_point)
		spawn_points.append(spawn_point.get_origin().x)
	
	# Set up the rotation offset so the map starts level
	_spawn_point_average = 0
	for point in spawn_points:
		_spawn_point_average += point
	_spawn_point_average /= len(spawn_points)
	
	# Wait for the clients to all be ready
	if not multiplayer_lobby.all_players_ready():
		await multiplayer_lobby.players_ready
	
	_enable_rotation = true


@rpc("authority", "call_local", "reliable")
func _add_player(id: int, spawn_point: Transform2D) -> void:
	var player := multiplayer_lobby.get_player(id)
	var player_node := PLAYER.instantiate()
	player.set_character_node(player_node)
	
	floor_rotation_changed.connect(player_node.set_floor_rotation)
	player_container.add_child(player_node)
	
	player_node.global_transform = spawn_point
	
	if player.is_multiplayer_authority():
		player.set_state(Player.PlayerState.READY)
