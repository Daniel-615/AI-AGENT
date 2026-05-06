extends Control


func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")




func _on_volume_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/game_volume.tscn")
	
