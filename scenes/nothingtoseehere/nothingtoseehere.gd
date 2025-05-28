extends Node2D

@onready var agptraiwdf_6_ikczlwp_1z: Sprite2D = $Agptraiwdf6Ikczlwp1z


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var tween := get_tree().create_tween()
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(agptraiwdf_6_ikczlwp_1z, "rotation_degrees", 360, 1.0)
			tween.tween_property(agptraiwdf_6_ikczlwp_1z, "rotation_degrees", 0, 0.0)
