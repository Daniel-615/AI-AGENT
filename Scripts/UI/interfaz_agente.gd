extends Node


var barra_energia: ProgressBar
var label_rescatados: Label
var label_estado: Label
var label_bfs: Label
var label_a_estrella: Label
var label_conocimiento: Label
var label_bitacora: RichTextLabel
var label_muerte: Label


var mensajes_bitacora := []
var max_mensajes := 28

var muertes := 0


func configurar(canvas_layer: CanvasLayer):
	barra_energia = canvas_layer.get_node_or_null("%BarraEnergia")
	label_rescatados = canvas_layer.get_node_or_null("%LabelRescatados")
	label_estado = canvas_layer.get_node_or_null("%LabelEstados")
	label_bfs = canvas_layer.get_node_or_null("%LabelBFS")
	label_a_estrella = canvas_layer.get_node_or_null("%LabelAEstrella")
	label_conocimiento = canvas_layer.get_node_or_null("%LabelConocimiento")
	label_bitacora = canvas_layer.get_node_or_null("%LabelBitacora")
	label_muerte = canvas_layer.get_node_or_null("%LabelMuertes")

	if barra_energia == null \
	or label_rescatados == null \
	or label_bitacora == null \
	or label_muerte == null:

		print("--- ERROR DE INTERFAZ ---")
		print("No se encontraron algunos nodos.")
	
	else:
		label_bitacora.bbcode_enabled = true
		label_bitacora.clear()

		# Inicializar contador de muertes
		label_muerte.text = "Muertes: 0"

func actualizar(
	personas_rescatadas: int,
	energia_actual: int,
	energia_max: int,
	ultimo_bfs_nodos: int,
	ultimo_a_nodos: int,
	peligros_conocidos: int,
	recargas_conocidas: int
):

	if label_rescatados:
		label_rescatados.text = "Rescatados: " + str(personas_rescatadas)

	if label_bfs:
		label_bfs.text = "BFS nodos: " + str(ultimo_bfs_nodos)

	if label_a_estrella:
		label_a_estrella.text = "A* nodos: " + str(ultimo_a_nodos)

	if barra_energia:
		barra_energia.max_value = energia_max
		barra_energia.value = energia_actual

	if label_conocimiento:
		label_conocimiento.text = (
			"Peligros: "
			+ str(peligros_conocidos)
			+ " | Recargas: "
			+ str(recargas_conocidas)
		)
func cambiar_estado(nuevo_estado: String):
	label_estado.text = "Estado: " + nuevo_estado.to_upper()



func agregar_muerte():
	muertes += 1
	print(muertes)
	if label_muerte:
		label_muerte.text = "Muertes: " + str(muertes)

	agregar_mensaje("El robot ha sido destruido.")
	


func agregar_mensaje(mensaje: String):
	var color = "#ffffff"
	var icono = "• "

	var msj_low = mensaje.to_lower()

	if "peligro" in msj_low or "trampa" in msj_low:
		color = "#ff5555"
		icono = "⚠ "

	elif "rescatada" in msj_low \
	or "éxito" in msj_low \
	or "terminada" in msj_low:

		color = "#50ff77"
		icono = "✔ "

	elif "energía" in msj_low \
	or "recarga" in msj_low \
	or "batería" in msj_low:

		color = "#f1fa8c"
		icono = "⚡ "

	elif "moviendo" in msj_low:
		color = "#8be9fd"
		icono = "➡ "

	elif "destruido" in msj_low or "muerte" in msj_low:
		color = "#ff2222"
		icono = "☠ "

	var mensaje_formateado = (
		"[color="
		+ color
		+ "]"
		+ icono
		+ mensaje
		+ "[/color]"
	)

	mensajes_bitacora.append(mensaje_formateado)

	if mensajes_bitacora.size() > max_mensajes:
		mensajes_bitacora.pop_front()

	_actualizar_texto_bitacora()


func _actualizar_texto_bitacora():
	label_bitacora.clear()

	label_bitacora.append_text(
		"[b][u][color=negro]BITÁCORA DE MISIÓN[/color][/u][/b]\n\n"
	)

	for m in mensajes_bitacora:
		label_bitacora.append_text(m + "\n")
