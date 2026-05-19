extends Control

func _ready():

	$VBoxContainer2/labelMuerte.text = (
		"Muertes: " + str(Config.muertes)
	)

	$VBoxContainer2/labelPeligros.text = (
		"Peligros: " + str(Config.peligros_detectados)
	)

	$VBoxContainer2/labelRecargas.text = (
		"Recargas: " + str(Config.recargas_encontradas)
	)

	$VBoxContainer2/labelRescatados.text = (
		"Rescatados: " + str(Config.personas_rescatadas)
	)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://Escenas/game_options.tscn"
	)
