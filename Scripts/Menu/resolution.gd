extends Control

@onready var display_options = $VBoxContainer/Resolution


func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://Escenas/options.tscn"
	)


func _on_resolution_item_selected(index: int) -> void:
	Config.change_displayMode(index)
