extends Node

var metodo_busqueda := "A"
var juego_iniciado := false
var dialogo_iniciado := false

var personas_rescatadas = 0
var peligros_detectados = 0
var recargas_encontradas = 0
var bfs_nodos = 0
var a_nodos = 0
var muertes= 0
func reset_estadisticas():
	personas_rescatadas = 0
	peligros_detectados = 0
	recargas_encontradas = 0
	bfs_nodos = 0
	a_nodos = 0
	muertes =0
func change_displayMode(index):

	var window = get_window()

	match index:

		0:

			window.mode = Window.MODE_WINDOWED

		1:

			window.mode = Window.MODE_FULLSCREEN
