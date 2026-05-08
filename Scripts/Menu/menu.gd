extends Control
const WELCOME = preload("res://Dialogues/welcome.dialogue")

func _ready():
	if Config.dialogo_iniciado ==false:
		DialogueManager.show_dialogue_balloon(WELCOME, "start")
		Config.dialogo_iniciado=true
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/game_options.tscn")
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/options.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
