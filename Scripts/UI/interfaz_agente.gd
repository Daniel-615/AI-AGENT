extends Node

var barra_energia: ProgressBar
var label_rescatados: Label
var label_estado: Label
var label_bfs: Label
var label_a_estrella: Label
var label_conocimiento: Label
var label_bitacora: Label
var mensajes_bitacora := []
var max_mensajes := 5

func configurar(canvas_layer: CanvasLayer):
	barra_energia = canvas_layer.get_node("BarraEnergia")
	label_rescatados = canvas_layer.get_node("LabelRescatados")
	label_estado = canvas_layer.get_node("LabelEstados")
	label_bfs = canvas_layer.get_node("LabelBFS")
	label_a_estrella = canvas_layer.get_node("LabelAEstrella")
	label_conocimiento = canvas_layer.get_node("LabelConocimiento")
	label_bitacora = canvas_layer.get_node("LabelBitacora")

func actualizar(
	personas_rescatadas: int,
	energia_actual: int,
	energia_max: int,
	ultimo_bfs_nodos: int,
	ultimo_a_nodos: int,
	peligros_conocidos: int,
	recargas_conocidas: int
):
	label_rescatados.text = "Rescatados: " + str(personas_rescatadas)
	label_bfs.text = "BFS nodos: " + str(ultimo_bfs_nodos)
	label_a_estrella.text = "A* nodos: " + str(ultimo_a_nodos)
	
	barra_energia.max_value = energia_max
	barra_energia.value = energia_actual
	
	label_conocimiento.text = "Conocimiento → Peligros: " + str(peligros_conocidos) + " | Recargas: " + str(recargas_conocidas)

func cambiar_estado(nuevo_estado: String):
	label_estado.text = "Estado: " + nuevo_estado
	
func agregar_mensaje(mensaje: String):
	mensajes_bitacora.append(mensaje)
	
	if mensajes_bitacora.size() > max_mensajes:
		mensajes_bitacora.pop_front()
	
	var texto := "Bitácora:\n"
	
	for m in mensajes_bitacora:
		texto += "- " + m + "\n"
	
	label_bitacora.text = texto
