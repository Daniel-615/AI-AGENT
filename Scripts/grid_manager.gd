extends Node2D

const CELL_SIZE := 48

const WIDTH := 20
const HEIGHT := 15

const VACIO := 0
const PARED := 1
const PERSONA := 2
const PELIGRO := 3
const RECARGA := 4

var grid := []

var icono_persona = preload("res://Sprites/persona.png")
var icono_bebida= preload("res://Sprites/energia.png")
func _ready():
	generar_mapa()
	poblar_mapa()
	colocar_personas(3)
	queue_redraw()

func generar_mapa():
	grid.clear()
	
	for y in range(HEIGHT):
		var fila := []
		for x in range(WIDTH):
			fila.append(VACIO)
		grid.append(fila)

func poblar_mapa():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var r = rng.randi_range(0, 100)
			
			if r < 15:
				grid[y][x] = PARED
			elif r < 20:
				grid[y][x] = PELIGRO
			elif r < 23:
				grid[y][x] = RECARGA
			else:
				grid[y][x] = VACIO

func colocar_personas(cantidad: int):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var colocadas = 0
	
	while colocadas < cantidad:
		var x = rng.randi_range(0, WIDTH - 1)
		var y = rng.randi_range(0, HEIGHT - 1)
		
		if grid[y][x] == VACIO:
			grid[y][x] = PERSONA
			colocadas += 1

func _draw():
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var valor_celda = grid[y][x]
			var rect = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			
			var color_fondo := Color(0.90, 0.90, 0.90)
			
			if valor_celda == PARED:
				color_fondo = Color(0.15, 0.15, 0.15)
			elif valor_celda == PELIGRO:
				color_fondo = Color(1.0, 0.25, 0.25)
			elif valor_celda == RECARGA:
				color_fondo = Color(0.2, 1.0, 0.4)
			elif valor_celda == PERSONA:
				color_fondo = Color(0.2, 0.7, 1.0, 0.3)
			
			draw_rect(rect, color_fondo)

			if valor_celda == PERSONA:
				if icono_persona:
					draw_texture_rect(icono_persona, rect, false)
			if valor_celda ==RECARGA:
				if icono_bebida:
					draw_texture_rect(icono_bebida,rect,false)
			draw_rect(rect, Color.BLACK, false, 1)


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
