extends Control

const ROBOT_WELCOME = preload("res://Dialogues/robot.choose.dialogue")

func _ready():
	DialogueManager.show_dialogue_balloon(ROBOT_WELCOME, "start")

func _on_bfs_pressed() -> void:
	Config.metodo_busqueda = "BFS"
	Config.juego_iniciado = true
	get_tree().change_scene_to_file("res://Escenas/game.tscn")

func _on_a_pressed() -> void:
	Config.metodo_busqueda = "A"
	Config.juego_iniciado = true
	get_tree().change_scene_to_file("res://Escenas/game.tscn")

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")
