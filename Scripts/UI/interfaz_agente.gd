extends Node

# --- REFERENCIAS A NODOS ---
# Usamos el nombre único (%) para que no importe la ruta de las ramas
var barra_energia: ProgressBar
var label_rescatados: Label
var label_estado: Label
var label_bfs: Label
var label_a_estrella: Label
var label_conocimiento: Label
var label_bitacora: RichTextLabel # Importante: ahora es RichTextLabel

# --- VARIABLES DE CONTROL ---
var mensajes_bitacora := []
var max_mensajes := 28 # Cuántos mensajes se ven a la vez

func configurar(canvas_layer: CanvasLayer):
	# Usamos el % para buscar por nombre único en toda la escena
	barra_energia = canvas_layer.get_node_or_null("%BarraEnergia")
	label_rescatados = canvas_layer.get_node_or_null("%LabelRescatados")
	label_estado = canvas_layer.get_node_or_null("%LabelEstados")
	label_bfs = canvas_layer.get_node_or_null("%LabelBFS")
	label_a_estrella = canvas_layer.get_node_or_null("%LabelAEstrella")
	label_conocimiento = canvas_layer.get_node_or_null("%LabelConocimiento")
	label_bitacora = canvas_layer.get_node_or_null("%LabelBitacora")

	# Verificación de seguridad
	if barra_energia == null or label_rescatados == null or label_bitacora == null:
		print("--- ERROR DE INTERFAZ ---")
		print("No se encontraron algunos nodos. Asegúrate de que tengan el '%' en la escena.")
	else:
		# Si todo está bien, configuramos la bitácora
		label_bitacora.bbcode_enabled = true
		label_bitacora.clear()

func actualizar(
	personas_rescatadas: int,
	energia_actual: int,
	energia_max: int,
	ultimo_bfs_nodos: int,
	ultimo_a_nodos: int,
	peligros_conocidos: int,
	recargas_conocidas: int
):
	# Actualizamos los textos con formato simple
	label_rescatados.text = "Rescatados: " + str(personas_rescatadas)
	label_bfs.text = "BFS nodos: " + str(ultimo_bfs_nodos)
	label_a_estrella.text = "A* nodos: " + str(ultimo_a_nodos)
	
	# Actualizamos la barra de energía
	barra_energia.max_value = energia_max
	barra_energia.value = energia_actual
	
	# Conocimiento con una pequeña distinción visual
	label_conocimiento.text = "Peligros: " + str(peligros_conocidos) + " | Recargas: " + str(recargas_conocidas)

func cambiar_estado(nuevo_estado: String):
	# Ponemos el estado en mayúsculas para que resalte
	label_estado.text = "Estado: " + nuevo_estado.to_upper()
	
func agregar_mensaje(mensaje: String):
	# Lógica de colores según el contenido del mensaje
	var color = "#ffffff" # Blanco por defecto
	var icono = "• "
	
	var msj_low = mensaje.to_lower()
	
	if "peligro" in msj_low or "trampa" in msj_low:
		color = "#ff5555" # Rojo
		icono = "⚠ "
	elif "rescatada" in msj_low or "éxito" in msj_low or "terminada" in msj_low:
		color = "#50ff77" # Verde
		icono = "✔ "
	elif "energía" in msj_low or "recarga" in msj_low or "batería" in msj_low:
		color = "#f1fa8c" # Amarillo
		icono = "⚡ "
	elif "moviendo" in msj_low:
		color = "#8be9fd" # Cian/Azul claro
		icono = "➡ "

	# Creamos la línea con formato BBCode
	var mensaje_formateado = "[color=" + color + "]" + icono + mensaje + "[/color]"
	
	mensajes_bitacora.append(mensaje_formateado)
	
	# Mantener solo los últimos mensajes
	if mensajes_bitacora.size() > max_mensajes:
		mensajes_bitacora.pop_front()
	
	# Refrescar el contenido de la RichTextLabel
	_actualizar_texto_bitacora()

func _actualizar_texto_bitacora():
	label_bitacora.clear()
	# Título de la bitácora con negrita y subrayado
	label_bitacora.append_text("[b][u][color=negro]BITÁCORA DE MISIÓN[/color][/u][/b]\n\n")
	
	for m in mensajes_bitacora:
		label_bitacora.append_text(m + "\n")
