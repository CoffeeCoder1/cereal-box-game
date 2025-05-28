extends Node2D

const PLAYER = preload("res://scenes/games/maze/maze_player/maze_player.tscn")

@onready var pivot: Node2D = $Pivot
@onready var player_container: Node = $Players
@onready var spawn_point_1: Marker2D = $SpawnPoint1
@onready var spawn_point_2: Marker2D = $SpawnPoint2

signal floor_rotation_changed(new_rotation: float)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var position_average: float
	for player in player_container.get_children():
		player = player as MazePlayer
		if is_instance_valid(player):
			position_average += player.position.x
	position_average /= player_container.get_child_count()
	
	pivot.rotation = position_average / 200 + PI
	floor_rotation_changed.emit(pivot.rotation)


func start_game(players: Array[Player]) -> void:
	for player in players:
		var player_node = PLAYER.instantiate()
		floor_rotation_changed.connect(player_node.set_floor_rotation)
		player_container.add_child(player_node)
		
		# Move the player to a spawn point
		player_node.global_transform = spawn_point_1.global_transform if player_container.get_child_count() % 2 == 1 else spawn_point_2.global_transform
