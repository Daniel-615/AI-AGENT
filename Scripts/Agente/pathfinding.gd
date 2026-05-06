extends Node

var nodos_bfs := 0
var nodos_a_estrella := 0

func bfs(inicio: Vector2i, objetivo: Vector2i, grid_manager: Node) -> Array:
	nodos_bfs = 0
	
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

func a_estrella(inicio: Vector2i, objetivo: Vector2i, grid_manager: Node, memoria_peligro: Dictionary) -> Array:
	nodos_a_estrella = 0
	
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
