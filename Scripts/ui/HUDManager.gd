class_name HUDManager
extends CanvasLayer

@onready var barra_energia: ProgressBar = $BarraEnergia
@onready var label_rescatados: Label = $LabelRescatados
@onready var label_estado: Label = $LabelEstados
@onready var label_a_estrella: Label = $LabelAEstrella

func actualizar(info: Dictionary):
	# Actualiza la barra de energía
	if barra_energia:
		barra_energia.max_value = info.energia_max
		barra_energia.value = info.energia
	
	# Actualiza los textos
	if label_rescatados:
		label_rescatados.text = "Rescatados: " + str(info.rescatados)
	
	if label_estado:
		label_estado.text = "Estado: " + str(info.estado)
		
	if label_a_estrella:
		label_a_estrella.text = "Nodos A*: " + str(info.nodos_a)
