extends Area2D

func _on_area_entered(area: Area2D) -> void:
	print("Colision con ", area.get_overlapping_bodies()[0])
