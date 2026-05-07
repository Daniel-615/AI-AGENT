extends HSlider

func _ready():
	min_value = 0
	max_value = 100
	value = 50
	
	value_changed.connect(_on_value_changed)

func _on_value_changed(valor):
	var db = linear_to_db(valor / 100.0)
	AudioServer.set_bus_volume_db(0, db)
