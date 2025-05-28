class_name DifferenceArea extends Area2D

@export var indicator: Node2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			indicator.show()
