extends Control


func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://Escenas/options.tscn"
	)


func _on_resolution_item_selected(index: int) -> void:
	match index:
		
		# Ventana
		0:
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
		
		
		# Pantalla completa
		1:
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN
			)
		
		
		# Pantalla completa sin bordes
		2:
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				true
			)
			
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN
			)
