extends Node2D

const CELL_SIZE := 48

const VACIO := 0
const PARED := 1
const PERSONA := 2
const PELIGRO := 3
const RECARGA := 4

const ANCHO := 15
const ALTO := 15

const PROB_PARED := 0.15
const PROB_PELIGRO := 0.10

var grid := []

var icono_persona = preload("res://Sprites/persona.png")
var icono_bebida = preload("res://Sprites/energia.png")


func _ready():
	randomize()
	generar_mapa()
	queue_redraw()


func generar_mapa():
	grid.clear()
	
	for y in range(ALTO):
		var fila := []
		
		for x in range(ANCHO):
			var r = randf()
			
			if r < PROB_PARED:
				fila.append(PARED)
			
			elif r < PROB_PARED + PROB_PELIGRO:
				fila.append(PELIGRO)
			
			else:
				fila.append(VACIO)
		
		grid.append(fila)
	
	# Asegurar inicio libre
	grid[0][0] = VACIO
	
	# Generar elementos seguros
	generar_personas_seguras(5)
	generar_recargas_seguras(3)


func generar_personas_seguras(cantidad):
	var colocadas := 0
	var intentos := 0
	
	while colocadas < cantidad and intentos < 500:
		intentos += 1
		
		var pos = Vector2i(
			randi() % ANCHO,
			randi() % ALTO
		)
		
		if obtener_valor_celda(pos) != VACIO:
			continue
		
		# Debe ser segura
		if not posicion_segura(pos):
			continue
		
		# Debe poder alcanzarse desde inicio
		if not es_alcanzable(Vector2i(0, 0), pos):
			continue
		
		grid[pos.y][pos.x] = PERSONA
		colocadas += 1


func generar_recargas_seguras(cantidad):
	var colocadas := 0
	var intentos := 0
	
	while colocadas < cantidad and intentos < 500:
		intentos += 1
		
		var pos = Vector2i(
			randi() % ANCHO,
			randi() % ALTO
		)
		
		if obtener_valor_celda(pos) != VACIO:
			continue
		
		if not posicion_segura(pos):
			continue
		
		if not es_alcanzable(Vector2i(0, 0), pos):
			continue
		
		grid[pos.y][pos.x] = RECARGA
		colocadas += 1


func posicion_segura(pos: Vector2i) -> bool:
	if not es_posicion_valida(pos):
		return false
	
	var direcciones = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	
	var libres := 0
	
	for d in direcciones:
		var vecino = pos + d
		
		if not esta_dentro_del_mapa(vecino):
			continue
		
		var valor = obtener_valor_celda(vecino)
		
		# No puede estar rodeado
		if valor != PARED and valor != PELIGRO:
			libres += 1
	
	# Debe tener al menos 2 salidas
	return libres >= 2


func es_alcanzable(inicio: Vector2i, objetivo: Vector2i) -> bool:
	var cola := []
	var visitados := {}
	
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
		
		if actual == objetivo:
			return true
		
		for d in direcciones:
			var vecino = actual + d
			
			if es_posicion_valida(vecino) \
			and not visitados.has(vecino):
				
				# BFS evita peligros
				if obtener_valor_celda(vecino) == PELIGRO:
					continue
				
				visitados[vecino] = true
				cola.append(vecino)
	
	return false


func _draw():
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var valor_celda = grid[y][x]
			
			var rect = Rect2(
				x * CELL_SIZE,
				y * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE
			)
			
			var color := Color.WHITE
			
			match valor_celda:
				VACIO:
					color = Color(0.90, 0.90, 0.90)
				
				PARED:
					color = Color(0.15, 0.15, 0.15)
				
				PELIGRO:
					color = Color(1.0, 0.25, 0.25)
				
				PERSONA, RECARGA:
					color = Color(0.90, 0.90, 0.90)
			
			# Fondo
			draw_rect(rect, color)
			
			# Sprites
			match valor_celda:
				PERSONA:
					if icono_persona:
						draw_texture_rect(
							icono_persona,
							rect,
							false
						)
				
				RECARGA:
					if icono_bebida:
						draw_texture_rect(
							icono_bebida,
							rect,
							false
						)
			
			# Bordes
			draw_rect(
				rect,
				Color.BLACK,
				false,
				2
			)


func es_posicion_valida(pos: Vector2i) -> bool:
	if pos.y < 0 or pos.y >= grid.size():
		return false
	
	if pos.x < 0 or pos.x >= grid[pos.y].size():
		return false
	
	if grid[pos.y][pos.x] == PARED:
		return false
	
	return true


func esta_dentro_del_mapa(pos: Vector2i) -> bool:
	return (
		pos.y >= 0
		and pos.y < grid.size()
		and pos.x >= 0
		and pos.x < grid[pos.y].size()
	)


func obtener_valor_celda(pos: Vector2i) -> int:
	if not esta_dentro_del_mapa(pos):
		return -1
	
	return grid[pos.y][pos.x]


func cambiar_valor_celda(pos: Vector2i, nuevo_valor: int):
	if not esta_dentro_del_mapa(pos):
		return
	
	grid[pos.y][pos.x] = nuevo_valor
	
	queue_redraw()


func es_persona(pos: Vector2i) -> bool:
	return obtener_valor_celda(pos) == PERSONA


func es_recarga(pos: Vector2i) -> bool:
	return obtener_valor_celda(pos) == RECARGA


func obtener_posiciones_personas() -> Array:
	var personas := []
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == PERSONA:
				personas.append(Vector2i(x, y))
	
	return personas


func obtener_posiciones_recarga() -> Array:
	var estaciones := []
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == RECARGA:
				estaciones.append(Vector2i(x, y))
	
	return estaciones
