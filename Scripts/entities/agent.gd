extends Node2D

const CELL_SIZE := 48
const COSTO_MOV := 4

# Dependencias
var knowledge := knowledgeBase.new()
@onready var grid_manager := get_parent().get_node("GridManager")
@onready var hud := get_parent().get_node("CanvasLayer") 

var posicion_grid := Vector2i(0, 0)
var energia := 100
var energia_max := 100
var personas_rescatadas := 0
var camino_actual := []
var estado_actual := "Esperando"
var temporizador := 0.0
var tiempo_paso := 0.35
var ultimo_nodos_a := 0

func _ready():
	actualizar_vista()

func _process(delta):
	temporizador += delta
	if temporizador >= tiempo_paso:
		temporizador = 0.0
		ejecutar_ciclo()

func ejecutar_ciclo():
	#estado para evitar que se mueva si se queda sin stamina
	if energia<= 0: 
		estado_actual= "Sin energía"
		notificar_ui()
		return
	if camino_actual.is_empty():
		planificar()
	
	if not camino_actual.is_empty():
		mover_a(camino_actual.pop_front())
	
	notificar_ui()

func planificar():
	var personas = grid_manager.obtener_posiciones_personas()
	if personas.is_empty():
		estado_actual = "Misión completada"
		return

	var resultado = pathFinder.a_star(posicion_grid, personas[0], grid_manager, knowledge.memoria_peligro)
	camino_actual = resultado.camino
	ultimo_nodos_a = resultado.nodos
	estado_actual = "Rescatando"

func mover_a(nueva_pos: Vector2i):
	posicion_grid = nueva_pos
	energia -= COSTO_MOV
	
	if grid_manager.has_method("marcar_paso_agente"):
		grid_manager.marcar_paso_agente(posicion_grid)
	
	verificar_celda()
	actualizar_vista()

func verificar_celda():
	if grid_manager.es_persona(posicion_grid):
		personas_rescatadas += 1
		grid_manager.cambiar_valor_celda(posicion_grid, 0)
		knowledge.registrar(posicion_grid, "persona")
	
	if grid_manager.obtener_valor_celda(posicion_grid) == grid_manager.PELIGRO:
		knowledge.agregar_penalizacion(posicion_grid, 60)
		knowledge.registrar(posicion_grid, "peligro")
	if grid_manager.es_recarga(posicion_grid):
		energia += 50
		knowledge.registrar(posicion_grid,"recarga")
		estado_actual="Recargando...."  
	if grid_manager.obtener_valor_celda(posicion_grid) == grid_manager.PELIGRO:
		energia -= 10
		knowledge.registrar(posicion_grid, "peligro")
		estado_actual="Peligro!"
func actualizar_vista():
	position = Vector2(posicion_grid * CELL_SIZE) + Vector2(CELL_SIZE/2, CELL_SIZE/2)

func notificar_ui():
	var info = {
		"energia": energia,
		"energia_max": energia_max,
		"rescatados": personas_rescatadas,
		"estado": estado_actual,
		"nodos_a": ultimo_nodos_a,
		"con_peligro": knowledge.contar_por_tipo("peligro"),
		"con_recarga": knowledge.contar_por_tipo("recarga")
	}
	if hud and hud.has_method("actualizar"):
		hud.actualizar(info)
