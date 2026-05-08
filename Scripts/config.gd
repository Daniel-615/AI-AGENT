extends Node

var metodo_busqueda := "A"
var juego_iniciado := false
var dialogo_iniciado := false

func change_displayMode(index):

	var window = get_window()

	match index:

		0:

			window.mode = Window.MODE_WINDOWED

		1:

			window.mode = Window.MODE_FULLSCREEN
