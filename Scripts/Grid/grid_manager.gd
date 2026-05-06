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
const PROB_PERSONA := 0.05
const PROB_RECARGA := 0.05

var grid := []

var icono_persona = preload("res://Sprites/persona.png")
var icono_bebida = preload("res://Sprites/energia.png")

func _ready():
	randomize()
	generar_mapa()
	asegurar_elementos_minimos()
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
			elif r < PROB_PARED + PROB_PELIGRO + PROB_PERSONA:
				fila.append(PERSONA)
			elif r < PROB_PARED + PROB_PELIGRO + PROB_PERSONA + PROB_RECARGA:
				fila.append(RECARGA)
			else:
				fila.append(VACIO)
		
		grid.append(fila)


func asegurar_elementos_minimos():
	if obtener_posiciones_personas().is_empty():
		grid[randi() % ALTO][randi() % ANCHO] = PERSONA
	
	if obtener_posiciones_recarga().is_empty():
		grid[randi() % ALTO][randi() % ANCHO] = RECARGA


func _draw():
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var valor_celda = grid[y][x]
			var rect = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			
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
			
			# fondo
			draw_rect(rect, color)
			
			# sprites
			match valor_celda:
				PERSONA:
					if icono_persona:
						draw_texture_rect(icono_persona, rect, false)
				RECARGA:
					if icono_bebida:
						draw_texture_rect(icono_bebida, rect, false)
			
			# borde
			draw_rect(rect, Color.BLACK, false, 2)


func es_posicion_valida(pos: Vector2i) -> bool:
	if pos.y < 0 or pos.y >= grid.size():
		return false
	
	if pos.x < 0 or pos.x >= grid[pos.y].size():
		return false
	
	if grid[pos.y][pos.x] == PARED:
		return false
	
	return true

func obtener_valor_celda(pos: Vector2i) -> int:
	if pos.y < 0 or pos.y >= grid.size():
		return -1
	
	if pos.x < 0 or pos.x >= grid[pos.y].size():
		return -1
	
	return grid[pos.y][pos.x]

func cambiar_valor_celda(pos: Vector2i, nuevo_valor: int):
	if pos.y < 0 or pos.y >= grid.size():
		return
	
	if pos.x < 0 or pos.x >= grid[pos.y].size():
		return
	
	grid[pos.y][pos.x] = nuevo_valor
	queue_redraw()

func es_persona(pos: Vector2i) -> bool:
	return obtener_valor_celda(pos) == PERSONA

func obtener_posiciones_personas() -> Array:
	var personas := []
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == PERSONA:
				personas.append(Vector2i(x, y))
	
	return personas

func es_recarga(pos: Vector2i) -> bool:
	return obtener_valor_celda(pos) == RECARGA

func obtener_posiciones_recarga() -> Array:
	var estaciones := []
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == RECARGA:
				estaciones.append(Vector2i(x, y))
	
	return estaciones
	
func esta_dentro_del_mapa(pos: Vector2i) -> bool:
	return pos.y >= 0 and pos.y < grid.size() and pos.x >= 0 and pos.x < grid[pos.y].size()
