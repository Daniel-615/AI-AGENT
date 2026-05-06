class_name pathFinder
extends RefCounted

static func a_star(inicio: Vector2i, objetivo: Vector2i, grid_manager: Node, memoria_peligro: Dictionary) -> Dictionary:
	var abiertos := []
	var padre := {}
	var g_score := {}
	var f_score := {}
	var nodos_explorados = 0
	
	abiertos.append(inicio)
	g_score[inicio] = 0
	f_score[inicio] = _heuristica(inicio, objetivo)
	
	var direcciones = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	
	while abiertos.size() > 0:
		var actual = _obtener_menor_f(abiertos, f_score)
		nodos_explorados += 1
		
		if actual == objetivo:
			return {"camino": _reconstruir(padre, inicio, objetivo), "nodos": nodos_explorados}
		
		abiertos.erase(actual)
		
		for dir in direcciones:
			var vecino = actual + dir
			if not grid_manager.es_posicion_valida(vecino): continue
			
			var costo_base = 1
			var costo_peligro = 40 if grid_manager.obtener_valor_celda(vecino) == grid_manager.PELIGRO else 0
			var penalizacion = memoria_peligro.get(vecino, 0)

			var tentative_g = g_score.get(actual, INF) + costo_base + costo_peligro + penalizacion
			
			if tentative_g < g_score.get(vecino, INF):
				padre[vecino] = actual
				g_score[vecino] = tentative_g
				f_score[vecino] = tentative_g + _heuristica(vecino, objetivo)
				if not abiertos.has(vecino): abiertos.append(vecino)
	
	return {"camino": [], "nodos": nodos_explorados}

static func _heuristica(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

static func _obtener_menor_f(lista: Array, f_score: Dictionary) -> Vector2i:
	var mejor = lista[0]
	for nodo in lista:
		if f_score.get(nodo, INF) < f_score.get(mejor, INF): mejor = nodo
	return mejor

static func _reconstruir(padre: Dictionary, inicio: Vector2i, objetivo: Vector2i) -> Array:
	var camino := []
	var actual = objetivo
	while actual != inicio:
		camino.insert(0, actual)
		actual = padre[actual]
	return camino
