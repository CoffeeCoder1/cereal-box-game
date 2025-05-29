extends Node2D

const PLAYER = preload("res://scenes/games/maze/maze_player/maze_player.tscn")

@export var multiplayer_lobby: MultiplayerLobby
@export var maze_rotation: float
@export var floor_rotation: float
@export var maze_scenes: Dictionary[String, PackedScene]

signal floor_rotation_changed(new_rotation: float)

@onready var player_container: Node = $Players
@onready var game_border: Area2D = $GameBorder
@onready var audio_stream_player_2d: AudioStreamPlayer = $AudioStreamPlayer2D
@onready var cereal_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _spawn_point_average: float
## Enables the rotation effect. Should be disabled until players are set up so
## the level doesn't rotate erratically.
var _enable_rotation: bool = false
var _maze: MazeLevel
var _last_sound_rotation: float = 0


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
		
		maze_rotation = lerp_angle(maze_rotation, (position_average - _spawn_point_average) / 200, delta * 10)
		
		# Find what the floor is (closest wall to being horizontal)
		floor_rotation = fposmod(maze_rotation + PI / 4, TAU)
		
		if (floor_rotation >= 0 and floor_rotation < PI / 2):
			floor_rotation -= PI / 4
		elif (floor_rotation >= PI / 2 and floor_rotation < PI):
			floor_rotation += 5 * PI / 4
		elif (floor_rotation >= PI and floor_rotation < (3 * PI / 2)):
			floor_rotation += 3 * PI / 4
		else:
			floor_rotation += PI / 4
	
	if is_instance_valid(_maze):
		_maze.pivot.rotation = maze_rotation
	floor_rotation_changed.emit(floor_rotation)
	
	if abs(_last_sound_rotation - floor_rotation) > 0.2:
		audio_stream_player_2d.play(3.0)
		_last_sound_rotation = floor_rotation


## Sets up the game on all the clients. Should be called on the server.
func start_game() -> void:
	_enable_rotation = false
	
	maze_rotation = 0.0
	floor_rotation = 0.0
	
	# Pick a random level and load it
	var level: String = maze_scenes.keys().pick_random()
	_load_level.rpc(level)
	
	var spawn_points: Array[float]
	
	# Create the players
	for player in multiplayer_lobby.get_players():
		var spawn_point: Node2D = _maze.spawn_points.get(player_container.get_child_count() % len(_maze.spawn_points))
		_add_player.rpc(player.get_multiplayer_authority(), spawn_point.global_transform)
		spawn_points.append(spawn_point.global_transform.get_origin().x)
	
	# Set up the rotation offset so the map starts level
	_spawn_point_average = 0
	for point in spawn_points:
		_spawn_point_average += point
	_spawn_point_average /= len(spawn_points)
	
	# Wait for the clients to all be ready
	if not multiplayer_lobby.all_players_ready():
		await multiplayer_lobby.players_ready
	
	game_border.monitoring = true
	_enable_rotation = true


func reload_game() -> void:
	_unload_level.rpc()
	
	call_deferred("start_game")


@rpc("authority", "call_local", "reliable")
func _load_level(level_name: String) -> void:
	if is_instance_valid(_maze):
		_maze.queue_free()
	_maze = maze_scenes.get(level_name).instantiate()
	add_child(_maze)
	
	cereal_stream_player.play()


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


@rpc("authority", "call_local", "reliable")
func _unload_level() -> void:
	for player in player_container.get_children():
		if is_instance_valid(player):
			player_container.remove_child(player)
			player.queue_free()
	
	for player in multiplayer_lobby.get_players():
		if is_instance_valid(player):
			if player.is_multiplayer_authority():
				player.set_state(Player.PlayerState.LOADING)
	
	if is_instance_valid(_maze):
		_maze.queue_free()


func _on_game_border_body_entered(body: Node2D) -> void:
	if not body is MazePlayer:
		return
	
	# Needed to prevent a cycle of restarting the game as the players are killed
	game_border.set_deferred("monitoring", false)
	
	if multiplayer.is_server():
		reload_game()
