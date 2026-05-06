extends Node2D

const CELL_SIZE := 48

var pathfinding: Node
var energy_system: Node
var base_conocimiento: Node
var interfaz_agente: Node
var posicion_grid := Vector2i(0, 0)
var grid_manager: Node = null
var objetivo_actual := Vector2i(-1, -1)
var compromiso_rescate := false

var personas_rescatadas := 0
var camino_actual := []
var tiempo_entre_pasos := 0.35
var temporizador := 0.0

var ultimo_bfs_nodos := 0
var ultimo_a_nodos := 0

func _ready():
	grid_manager = get_parent().get_node("GridManager")
	pathfinding = get_node("Pathfinding")
	energy_system = get_node("EnergySystem")
	base_conocimiento = get_node("BaseConocimiento")
	interfaz_agente = get_node("InterfazAgente")
	interfaz_agente.configurar(get_parent().get_node("CanvasLayer"))
	
	actualizar_posicion_mundo()
	actualizar_ui()
	queue_redraw()


func _process(delta):
	temporizador += delta
	
	if temporizador >= tiempo_entre_pasos:
		temporizador = 0.0
		
		if not compromiso_rescate or camino_actual.size() == 0:
			buscar_objetivo()
		
		if camino_actual.size() > 0:
			posicion_grid = camino_actual.pop_front()
			energy_system.consumir_movimiento()
			
			actualizar_posicion_mundo()
			verificar_celda_actual()
			actualizar_ui()

func buscar_objetivo():
	var personas = grid_manager.obtener_posiciones_personas()
	var recargas = grid_manager.obtener_posiciones_recarga()
	
	if personas.size() == 0:
		interfaz_agente.cambiar_estado("Misión completada")
		actualizar_ui()
		return
	
	var estoy_en_recarga = grid_manager.es_recarga(posicion_grid)
	
	if estoy_en_recarga:
		energy_system.recargar()
	
	var mejor_camino_persona := []
	
	for persona in personas:
		var camino_bfs = pathfinding.bfs(posicion_grid, persona, grid_manager)
		var nodos_bfs_resultado = pathfinding.nodos_bfs
		
		var camino_a = pathfinding.a_estrella(posicion_grid, persona, grid_manager, base_conocimiento.memoria_peligro)
		var nodos_a_resultado = pathfinding.nodos_a_estrella
		
		if camino_a.size() > 0:
			print("Comparación hacia persona ", persona)
			print("BFS nodos explorados: ", nodos_bfs_resultado)
			print("A* nodos explorados: ", nodos_a_resultado)
			
			if mejor_camino_persona.size() == 0 or camino_a.size() < mejor_camino_persona.size():
				mejor_camino_persona = camino_a
				ultimo_bfs_nodos = nodos_bfs_resultado
				ultimo_a_nodos = nodos_a_resultado
	
	if mejor_camino_persona.size() == 0:
		interfaz_agente.cambiar_estado("Sin camino a persona")
		actualizar_ui()
		return
	
	var costo_ida = mejor_camino_persona.size() * energy_system.costo_movimiento
	var energia_minima_segura = 12
	
	if estoy_en_recarga and energy_system.tiene_energia_suficiente(costo_ida):
		interfaz_agente.cambiar_estado("Rescatando")
		objetivo_actual = mejor_camino_persona[-1]
		compromiso_rescate = false
		camino_actual = mejor_camino_persona
		actualizar_ui()
		return
	
	var costo_regreso_recarga = INF
	
	for r in recargas:
		var camino_recarga = pathfinding.a_estrella(mejor_camino_persona[-1], r, grid_manager, base_conocimiento.memoria_peligro)
		
		if camino_recarga.size() > 0:
			costo_regreso_recarga = min(costo_regreso_recarga, camino_recarga.size() * energy_system.costo_movimiento)
	
	var costo_total_seguro = costo_ida + costo_regreso_recarga
	
	if energy_system.tiene_energia_suficiente(costo_total_seguro) or energy_system.tiene_energia_suficiente(costo_ida + energia_minima_segura):
		interfaz_agente.cambiar_estado("Rescatando")
		objetivo_actual = mejor_camino_persona[-1]
		compromiso_rescate = false
		camino_actual = mejor_camino_persona
		actualizar_ui()
		return
	
	if recargas.size() > 0 and not estoy_en_recarga:
		interfaz_agente.cambiar_estado("Buscando recarga")
		
		var mejor_camino_recarga := []
		
		for r in recargas:
			var camino = pathfinding.a_estrella(posicion_grid, r, grid_manager, base_conocimiento.memoria_peligro)
			
			if camino.size() > 0:
				if mejor_camino_recarga.size() == 0 or camino.size() < mejor_camino_recarga.size():
					mejor_camino_recarga = camino
		
		camino_actual = mejor_camino_recarga
		actualizar_ui()
		return
	
	interfaz_agente.cambiar_estado("Esperando decisión")
	actualizar_ui()

func verificar_celda_actual():
	if grid_manager.es_persona(posicion_grid):
		personas_rescatadas += 1
		grid_manager.cambiar_valor_celda(posicion_grid, grid_manager.VACIO)
		base_conocimiento.registrar(posicion_grid, base_conocimiento.PERSONA_RESCATADA)
		objetivo_actual = Vector2i(-1, -1)
		compromiso_rescate = false
		camino_actual.clear()
	
	if grid_manager.es_recarga(posicion_grid):
		interfaz_agente.cambiar_estado("Recargando energía")
		energy_system.recargar()
		base_conocimiento.registrar(posicion_grid, base_conocimiento.RECARGA)
		compromiso_rescate = false
		
		if objetivo_actual == Vector2i(-1, -1):
			camino_actual.clear()
	
	if grid_manager.obtener_valor_celda(posicion_grid) == grid_manager.PELIGRO:
		base_conocimiento.registrar(posicion_grid, base_conocimiento.PELIGRO)
		base_conocimiento.aprender_peligro(posicion_grid, 60)
		
		if randf() < 0.6:
			energy_system.consumir_danio(50)
			base_conocimiento.aprender_peligro(posicion_grid, 60)
		
		if objetivo_actual != Vector2i(-1, -1):
			var camino_restante = pathfinding.a_estrella(posicion_grid, objetivo_actual, grid_manager, base_conocimiento.memoria_peligro)
			var costo_restante = camino_restante.size() * energy_system.costo_movimiento
			
			if camino_restante.size() > 0 and energy_system.tiene_energia_suficiente(costo_restante):
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

func actualizar_ui():
	interfaz_agente.actualizar(
		personas_rescatadas,
		energy_system.energia,
		energy_system.energia_max,
		ultimo_bfs_nodos,
		ultimo_a_nodos,
		base_conocimiento.contar(base_conocimiento.PELIGRO),
		base_conocimiento.contar(base_conocimiento.RECARGA)
	)
