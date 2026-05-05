extends Node2D

const CELL_SIZE := 48

var posicion_grid := Vector2i(0, 0)
var grid_manager: Node = null
var objetivo_actual := Vector2i(-1, -1)
var compromiso_rescate := false

var barra_energia: ProgressBar
var label_energia: Label
var label_rescatados: Label
var label_estado: Label
var label_bfs: Label
var label_a_estrella: Label
var label_conocimiento: Label

var personas_rescatadas := 0
var camino_actual := []
var tiempo_entre_pasos := 0.35
var temporizador := 0.0
var memoria_peligro := {}

var energia := 100
var energia_max := 100
var costo_movimiento := 4

var nodos_bfs := 0
var nodos_a_estrella := 0

var ultimo_bfs_nodos := 0
var ultimo_a_nodos := 0

var base_conocimiento := {}

const CONOCIMIENTO_PERSONA_RESCATADA := "persona_rescatada"
const CONOCIMIENTO_PELIGRO := "zona_peligrosa"
const CONOCIMIENTO_RECARGA := "estacion_recarga"

func _ready():
	grid_manager = get_parent().get_node("GridManager")
	
	barra_energia = get_parent().get_node("CanvasLayer/BarraEnergia")
	label_rescatados = get_parent().get_node("CanvasLayer/LabelRescatados")
	label_estado = get_parent().get_node("CanvasLayer/LabelEstados")
	label_bfs = get_parent().get_node("CanvasLayer/LabelBFS")
	label_a_estrella = get_parent().get_node("CanvasLayer/LabelAEstrella")
	label_conocimiento = get_parent().get_node("CanvasLayer/LabelConocimiento")
	
	
	actualizar_posicion_mundo()
	actualizar_ui()
	queue_redraw()


func _process(delta):
	temporizador += delta
	
	if temporizador >= tiempo_entre_pasos:
		temporizador = 0.0
		
		if not compromiso_rescate:
			buscar_objetivo()
		
		if camino_actual.size() > 0:
			posicion_grid = camino_actual.pop_front()
			energia -= costo_movimiento
			
			actualizar_posicion_mundo()
			verificar_celda_actual()
			actualizar_ui()

func buscar_objetivo():
	var personas = grid_manager.obtener_posiciones_personas()
	var recargas = grid_manager.obtener_posiciones_recarga()
	
	nodos_bfs = 0
	nodos_a_estrella = 0
	
	if personas.size() == 0:
		label_estado.text = "Estado: Misión completada"
		actualizar_ui()
		return
	
	var estoy_en_recarga = grid_manager.es_recarga(posicion_grid)
	
	if estoy_en_recarga:
		energia = energia_max
	
	var mejor_camino_persona := []
	
	for persona in personas:
		nodos_bfs = 0
		nodos_a_estrella = 0
		
		var camino_bfs = bfs(posicion_grid, persona)
		var nodos_bfs_resultado = nodos_bfs
		
		var camino_a = a_estrella(posicion_grid, persona)
		var nodos_a_resultado = nodos_a_estrella
		
		if camino_a.size() > 0:
			print("Comparación hacia persona ", persona)
			print("BFS nodos explorados: ", nodos_bfs_resultado)
			print("A* nodos explorados: ", nodos_a_resultado)
			
			if mejor_camino_persona.size() == 0 or camino_a.size() < mejor_camino_persona.size():
				mejor_camino_persona = camino_a
				ultimo_bfs_nodos = nodos_bfs_resultado
				ultimo_a_nodos = nodos_a_resultado
	
	if mejor_camino_persona.size() == 0:
		label_estado.text = "Estado: Sin camino a persona"
		actualizar_ui()
		return
	
	var costo_ida = mejor_camino_persona.size() * costo_movimiento
	var energia_minima_segura = 12
	
	if estoy_en_recarga and energia >= costo_ida:
		label_estado.text = "Estado: Rescatando"
		objetivo_actual = mejor_camino_persona[-1]
		compromiso_rescate = false
		camino_actual = mejor_camino_persona
		actualizar_ui()
		return
	
	var costo_regreso_recarga = INF
	
	for r in recargas:
		var camino_recarga = a_estrella(mejor_camino_persona[-1], r)
		
		if camino_recarga.size() > 0:
			costo_regreso_recarga = min(costo_regreso_recarga, camino_recarga.size() * costo_movimiento)
	
	var costo_total_seguro = costo_ida + costo_regreso_recarga
	
	if energia >= costo_total_seguro or energia >= costo_ida + energia_minima_segura:
		label_estado.text = "Estado: Rescatando"
		objetivo_actual = mejor_camino_persona[-1]
		camino_actual = mejor_camino_persona
		actualizar_ui()
		return
	
	if recargas.size() > 0 and not estoy_en_recarga:
		label_estado.text = "Estado: Recargando"
		
		var mejor_camino_recarga := []
		
		for r in recargas:
			var camino = a_estrella(posicion_grid, r)
			
			if camino.size() > 0:
				if mejor_camino_recarga.size() == 0 or camino.size() < mejor_camino_recarga.size():
					mejor_camino_recarga = camino
		
		camino_actual = mejor_camino_recarga
		actualizar_ui()
		return
	
	label_estado.text = "Estado: Esperando decisión"
	actualizar_ui()

func bfs(inicio: Vector2i, objetivo: Vector2i) -> Array:
	var cola := []
	var visitados := {}
	var padre := {}
	
	cola.append(inicio)
	visitados[inicio] = true
	
	var direcciones = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	
	while cola.size() > 0:
		var actual = cola.pop_front()
		nodos_bfs += 1
		
		if actual == objetivo:
			return reconstruir_camino(padre, inicio, objetivo)
		
		for direccion in direcciones:
			var vecino = actual + direccion
			
			if grid_manager.es_posicion_valida(vecino) and not visitados.has(vecino):
				cola.append(vecino)
				visitados[vecino] = true
				padre[vecino] = actual
	
	return []

func a_estrella(inicio: Vector2i, objetivo: Vector2i) -> Array:
	var abiertos := []
	var padre := {}
	var g_score := {}
	var f_score := {}
	
	abiertos.append(inicio)
	g_score[inicio] = 0
	f_score[inicio] = heuristica(inicio, objetivo)
	
	var direcciones = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	
	while abiertos.size() > 0:
		var actual = obtener_menor_f(abiertos, f_score)
		nodos_a_estrella += 1
		
		if actual == objetivo:
			return reconstruir_camino(padre, inicio, objetivo)
		
		abiertos.erase(actual)
		
		for direccion in direcciones:
			var vecino = actual + direccion
			
			if not grid_manager.es_posicion_valida(vecino):
				continue
			
			var costo_base = 1
			var costo_peligro = 0

			if grid_manager.obtener_valor_celda(vecino) == grid_manager.PELIGRO:
				costo_peligro = 40

			var penalizacion_aprendida = memoria_peligro.get(vecino, 0)

			var tentative_g = g_score.get(actual, INF) + costo_base + costo_peligro + penalizacion_aprendida
			
			if tentative_g < g_score.get(vecino, INF):
				padre[vecino] = actual
				g_score[vecino] = tentative_g
				f_score[vecino] = tentative_g + heuristica(vecino, objetivo)
				
				if not abiertos.has(vecino):
					abiertos.append(vecino)
	
	return []

func reconstruir_camino(padre: Dictionary, inicio: Vector2i, objetivo: Vector2i) -> Array:
	var camino := []
	var actual = objetivo
	
	while actual != inicio:
		camino.insert(0, actual)
		actual = padre[actual]
	
	return camino

func verificar_celda_actual():
	if grid_manager.es_persona(posicion_grid):
		personas_rescatadas += 1
		grid_manager.cambiar_valor_celda(posicion_grid, grid_manager.VACIO)
		registrar_conocimiento(posicion_grid, CONOCIMIENTO_PERSONA_RESCATADA)
		objetivo_actual = Vector2i(-1, -1)
		compromiso_rescate = false
		camino_actual.clear()
	
	if grid_manager.es_recarga(posicion_grid):
		energia = energia_max
		registrar_conocimiento(posicion_grid, CONOCIMIENTO_RECARGA)
		compromiso_rescate = false
		
		if objetivo_actual == Vector2i(-1, -1):
			camino_actual.clear()
	
	if grid_manager.obtener_valor_celda(posicion_grid) == grid_manager.PELIGRO:
		registrar_conocimiento(posicion_grid, CONOCIMIENTO_PELIGRO)
		memoria_peligro[posicion_grid] = memoria_peligro.get(posicion_grid, 0) + 60
		
		if randf() < 0.6:
			energia -= 50
			memoria_peligro[posicion_grid] += 60
		
		if objetivo_actual != Vector2i(-1, -1):
			var camino_restante = a_estrella(posicion_grid, objetivo_actual)
			var costo_restante = camino_restante.size() * costo_movimiento
			
			if camino_restante.size() > 0 and energia >= costo_restante:
				compromiso_rescate = true
				camino_actual = camino_restante
			else:
				compromiso_rescate = false
				camino_actual.clear()
		else:
			compromiso_rescate = false
			camino_actual.clear()
		
	actualizar_ui()

func actualizar_posicion_mundo():
	position = Vector2(
		posicion_grid.x * CELL_SIZE + CELL_SIZE / 2,
		posicion_grid.y * CELL_SIZE + CELL_SIZE / 2
	)

func _draw():
	draw_circle(Vector2.ZERO, CELL_SIZE * 0.30, Color(1.0, 0.8, 0.1))
	draw_circle(Vector2.ZERO, CELL_SIZE * 0.30, Color.BLACK, false, 2)

func heuristica(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func obtener_menor_f(lista: Array, f_score: Dictionary) -> Vector2i:
	var mejor = lista[0]
	var mejor_valor = f_score.get(mejor, INF)
	
	for nodo in lista:
		var valor = f_score.get(nodo, INF)
		if valor < mejor_valor:
			mejor = nodo
			mejor_valor = valor
	
	return mejor

func actualizar_ui():
	energia = clamp(energia, 0, energia_max)
	
	label_rescatados.text = "Rescatados: " + str(personas_rescatadas)
	label_bfs.text = "BFS nodos: " + str(ultimo_bfs_nodos)
	label_a_estrella.text = "A* nodos: " + str(ultimo_a_nodos)
	barra_energia.max_value = energia_max
	barra_energia.value = energia
	label_conocimiento.text = "Conocimiento → Peligros: " + str(contar_conocimiento(CONOCIMIENTO_PELIGRO)) + " | Recargas: " + str(contar_conocimiento(CONOCIMIENTO_RECARGA))
	
	print("BFS nodos:", nodos_bfs)
	print("A* nodos:", nodos_a_estrella)
	
func registrar_conocimiento(pos: Vector2i, tipo: String):
	base_conocimiento[pos] = tipo

func contar_conocimiento(tipo: String) -> int:
	var total := 0
	
	for clave in base_conocimiento.keys():
		if base_conocimiento[clave] == tipo:
			total += 1
	
	return total
