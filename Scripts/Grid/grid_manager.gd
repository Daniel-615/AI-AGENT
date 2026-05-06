extends Node2D

const CELL_SIZE := 48

const VACIO := 0
const PARED := 1
const PERSONA := 2
const PELIGRO := 3
const RECARGA := 4

var grid := [
	[0, 0, 0, 0, 1, 0, 1, 0, 0, 0],
	[0, 1, 1, 0, 0, 0, 3, 0, 0, 4],
	[0, 0, 1, 0, 1, 0, 3, 1, 0, 0],
	[0, 0, 1, 0, 1, 0, 1, 0, 1, 0],
	[0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
	[0, 0, 1, 4, 3, 0, 1, 0, 3, 3],
	[0, 1, 1, 1, 3, 2, 1, 3, 3, 3],
	[0, 0, 0, 0, 1, 1, 1, 0, 0, 2],
]

func _ready():
	queue_redraw()

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
				PERSONA:
					color = Color(0.2, 0.7, 1.0)
				PELIGRO:
					color = Color(1.0, 0.25, 0.25)
				RECARGA:
					color = Color(0.2, 1.0, 0.4)
			
			draw_rect(rect, color)
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
