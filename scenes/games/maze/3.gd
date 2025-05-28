extends Node2D

@onready var pivot: Node2D = $Pivot
@onready var player: RigidBody2D = $Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pivot.rotation = player.position.x / 200
	player.floor_rotation = pivot.rotation
