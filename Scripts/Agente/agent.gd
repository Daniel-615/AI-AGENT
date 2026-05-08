extends Node2D

const CELL_SIZE := 48

var pathfinding: Node
var energy_system: Node
var base_conocimiento: Node
var interfaz_agente: Node
var sensor_agente: Node

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

var textura_agente = preload("res://Sprites/robot.png")


func _ready():
	grid_manager = get_parent().get_node("GridManager")
	pathfinding = get_node("Pathfinding")
	energy_system = get_node("EnergySystem")
	base_conocimiento = get_node("BaseConocimiento")
	interfaz_agente = get_node("InterfazAgente")
	sensor_agente = get_node("SensorAgente")
	
	interfaz_agente.configurar(
		get_parent().get_node("CanvasLayer")
	)
	actualizar_posicion_mundo()
	actualizar_ui()
	
	sensor_agente.percibir(
		posicion_grid,
		grid_manager,
		base_conocimiento,
		interfaz_agente
	)
	
	queue_redraw()


func _process(delta):
	if not Config.juego_iniciado:
		return
	
	temporizador += delta
	
	if energy_system.energia <= 0:
		interfaz_agente.cambiar_estado(
			"Sin energía - reiniciando"
		)
		
		camino_actual.clear()
		
		interfaz_agente.agregar_muerte()
		
		reiniciar_agente()
		return
	
	if temporizador >= tiempo_entre_pasos:
		temporizador = 0.0
		
		if not compromiso_rescate or camino_actual.size() == 0:
			buscar_objetivo()
		
		if camino_actual.size() > 0:
			posicion_grid = camino_actual.pop_front()
			
			energy_system.consumir_movimiento()
			
			base_conocimiento.registrar(
				posicion_grid,
				base_conocimiento.CELDA_CONOCIDA
			)
			
			actualizar_posicion_mundo()
			
			sensor_agente.percibir(
				posicion_grid,
				grid_manager,
				base_conocimiento,
				interfaz_agente
			)
			
			verificar_celda_actual()
			actualizar_ui()


func reiniciar_agente():
	Config.juego_iniciado = false
	
	await get_tree().create_timer(2.0).timeout
	
	interfaz_agente.agregar_mensaje(
		"Nuevo intento usando memoria aprendida"
	)
	
	posicion_grid = Vector2i(0, 0)
	actualizar_posicion_mundo()
	
	energy_system.energia = energy_system.energia_max
	
	camino_actual.clear()
	objetivo_actual = Vector2i(-1, -1)
	compromiso_rescate = false
	
	
	actualizar_ui()
	
	Config.juego_iniciado = true


func calcular_camino(origen, destino):
	if Config.metodo_busqueda == "BFS":
		var camino = pathfinding.bfs(
			origen,
			destino,
			grid_manager
		)
		
		ultimo_bfs_nodos = pathfinding.nodos_bfs
		
		return camino
	
	else:
		var camino = pathfinding.a_estrella(
			origen,
			destino,
			grid_manager,
			base_conocimiento.memoria_peligro
		)
		
		ultimo_a_nodos = pathfinding.nodos_a_estrella
		
		return camino


func buscar_objetivo():
	var personas = base_conocimiento.obtener_posiciones_por_tipo(
		base_conocimiento.PERSONA_DETECTADA
	)
	
	var recargas = grid_manager.obtener_posiciones_recarga()
	
	if energy_system.energia <= 25:
		interfaz_agente.cambiar_estado(
			"Energía crítica - buscando recarga"
		)
		
		var mejor_camino_recarga := []
		
		for r in recargas:
			var camino = calcular_camino(
				posicion_grid,
				r
			)
			
			if camino.size() > 0:
				if mejor_camino_recarga.size() == 0 \
				or camino.size() < mejor_camino_recarga.size():
					
					mejor_camino_recarga = camino
		
		if mejor_camino_recarga.size() > 0:
			camino_actual = mejor_camino_recarga
			actualizar_ui()
			return
	
	if personas.size() == 0:
		camino_actual = buscar_celda_no_visitada()
		
		if camino_actual.size() > 0:
			interfaz_agente.cambiar_estado(
				"Explorando entorno"
			)
		
		else:
			interfaz_agente.cambiar_estado(
				"Simulación terminada"
			)
			
			interfaz_agente.agregar_mensaje(
				"Todas las personas fueron rescatadas"
			)
			
			Config.juego_iniciado = false
			var robot_movimiento= get_parent().get_node("Musica")
			if robot_movimiento:
				robot_movimiento.stop()
		actualizar_ui()
		return
	
	var estoy_en_recarga = grid_manager.es_recarga(
		posicion_grid
	)
	
	if estoy_en_recarga:
		energy_system.recargar()
	
	var mejor_camino_persona := []
	
	for persona in personas:
		var camino = calcular_camino(
			posicion_grid,
			persona
		)
		
		if camino.size() > 0:
			if mejor_camino_persona.size() == 0 \
			or camino.size() < mejor_camino_persona.size():
				
				mejor_camino_persona = camino
	
	if mejor_camino_persona.size() == 0:
		interfaz_agente.cambiar_estado(
			"Sin camino a persona"
		)
		
		actualizar_ui()
		return
	
	var costo_ida = (
		mejor_camino_persona.size()
		* energy_system.costo_movimiento
	)
	
	var energia_minima_segura = 12
	
	if estoy_en_recarga \
	and energy_system.tiene_energia_suficiente(costo_ida):
		
		interfaz_agente.cambiar_estado("Rescatando")
		
		objetivo_actual = mejor_camino_persona[-1]
		compromiso_rescate = false
		camino_actual = mejor_camino_persona
		
		actualizar_ui()
		return
	
	var costo_regreso_recarga = INF
	
	for r in recargas:
		var camino_recarga = calcular_camino(
			mejor_camino_persona[-1],
			r
		)
		
		if camino_recarga.size() > 0:
			costo_regreso_recarga = min(
				costo_regreso_recarga,
				camino_recarga.size()
				* energy_system.costo_movimiento
			)
	
	var costo_total_seguro = (
		costo_ida + costo_regreso_recarga
	)
	
	if energy_system.tiene_energia_suficiente(
		costo_total_seguro
	) or energy_system.tiene_energia_suficiente(
		costo_ida + energia_minima_segura
	):
		
		interfaz_agente.cambiar_estado("Rescatando")
		
		objetivo_actual = mejor_camino_persona[-1]
		compromiso_rescate = false
		camino_actual = mejor_camino_persona
		
		actualizar_ui()
		return
	
	# Buscar recarga
	if recargas.size() > 0 and not estoy_en_recarga:
		interfaz_agente.cambiar_estado(
			"Buscando recarga"
		)
		
		var mejor_camino_recarga := []
		
		for r in recargas:
			var camino = calcular_camino(
				posicion_grid,
				r
			)
			
			if camino.size() > 0:
				if mejor_camino_recarga.size() == 0 \
				or camino.size() < mejor_camino_recarga.size():
					
					mejor_camino_recarga = camino
		
		camino_actual = mejor_camino_recarga
		
		actualizar_ui()
		return
	
	interfaz_agente.cambiar_estado(
		"Esperando decisión"
	)
	
	actualizar_ui()


func verificar_celda_actual():
	if grid_manager.es_persona(posicion_grid):
		personas_rescatadas += 1
		var persona_rescatada= get_parent().get_node("Persona")
		if persona_rescatada:
			persona_rescatada.play()
			var timer = get_tree().create_timer(1.0)
			timer.timeout.connect(
				func():
					persona_rescatada.stop()
			)
		grid_manager.cambiar_valor_celda(
			posicion_grid,
			grid_manager.VACIO
		)
		
		base_conocimiento.registrar(
			posicion_grid,
			base_conocimiento.PERSONA_RESCATADA
		)
		
		interfaz_agente.agregar_mensaje(
			"Persona rescatada en "
			+ str(posicion_grid)
		)
		
		objetivo_actual = Vector2i(-1, -1)
		compromiso_rescate = false
		camino_actual.clear()
	
	if grid_manager.es_recarga(posicion_grid):
		interfaz_agente.cambiar_estado(
			"Recargando energía"
		)
		var sonido_energia= get_parent().get_node("Energia")
		if sonido_energia:
			sonido_energia.play()
			var timer = get_tree().create_timer(1.0)
			timer.timeout.connect(
				func():
					sonido_energia.stop()
			)
		energy_system.recargar()
	
		interfaz_agente.agregar_mensaje(
			"Estación encontrada en "
			+ str(posicion_grid)
		)
	
		# Eliminar estación del mapa
		grid_manager.cambiar_valor_celda(
			posicion_grid,
			grid_manager.VACIO
		)
	
		base_conocimiento.registrar(
			posicion_grid,
			base_conocimiento.RECARGA
		)
	
		compromiso_rescate = false
	
	if objetivo_actual == Vector2i(-1, -1):
		camino_actual.clear()
	if grid_manager.obtener_valor_celda(
		posicion_grid
	) == grid_manager.PELIGRO:
		
		base_conocimiento.registrar(
			posicion_grid,
			base_conocimiento.PELIGRO
		)
		
		base_conocimiento.aprender_peligro(
			posicion_grid,
			60
		)
		
		interfaz_agente.agregar_mensaje(
			"Zona peligrosa detectada en "
			+ str(posicion_grid)
		)
		
		if randf() < 0.6:
			energy_system.consumir_danio(50)
			
			base_conocimiento.aprender_peligro(
				posicion_grid,
				60
			)
		
		if objetivo_actual != Vector2i(-1, -1):
			var camino_restante = calcular_camino(
				posicion_grid,
				objetivo_actual
			)
			
			var costo_restante = (
				camino_restante.size()
				* energy_system.costo_movimiento
			)
			
			if camino_restante.size() > 0 \
			and energy_system.tiene_energia_suficiente(
				costo_restante
			):
				
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
		posicion_grid.x * CELL_SIZE
		+ CELL_SIZE / 2,
		
		posicion_grid.y * CELL_SIZE
		+ CELL_SIZE / 2
	)


func _draw():
	if textura_agente:
		var size = CELL_SIZE * 0.8
		
		var rect = Rect2(
			Vector2(-size / 2, -size / 2),
			Vector2(size, size)
		)
		
		draw_texture_rect(
			textura_agente,
			rect,
			false
		)


func actualizar_ui():
	interfaz_agente.actualizar(
		personas_rescatadas,
		energy_system.energia,
		energy_system.energia_max,
		ultimo_bfs_nodos,
		ultimo_a_nodos,
		base_conocimiento.contar(
			base_conocimiento.PELIGRO
		),
		base_conocimiento.contar(
			base_conocimiento.RECARGA
		)
		
	)


func buscar_celda_no_visitada() -> Array:
	var mejor_camino := []
	
	for y in range(grid_manager.grid.size()):
		for x in range(grid_manager.grid[y].size()):
			var pos := Vector2i(x, y)
			
			if pos == posicion_grid:
				continue
			
			if not grid_manager.es_posicion_valida(pos):
				continue
			
			if base_conocimiento.conocimientos.has(pos):
				continue
			
			var camino = calcular_camino(
				posicion_grid,
				pos
			)
			
			if camino.size() > 0:
				if mejor_camino.size() == 0 \
				or camino.size() < mejor_camino.size():
					
					mejor_camino = camino
	
	return mejor_camino
