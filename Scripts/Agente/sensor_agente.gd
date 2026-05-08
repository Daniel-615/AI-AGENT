extends Node

var radio_percepcion := 2

func percibir(posicion_agente: Vector2i, grid_manager: Node, base_conocimiento: Node, interfaz_agente: Node):
	for y in range(posicion_agente.y - radio_percepcion, posicion_agente.y + radio_percepcion + 1):
		for x in range(posicion_agente.x - radio_percepcion, posicion_agente.x + radio_percepcion + 1):
			var pos := Vector2i(x, y)
			
			if not grid_manager.esta_dentro_del_mapa(pos):
				continue
			
			var valor = grid_manager.obtener_valor_celda(pos)
			
			if valor == grid_manager.VACIO:
				base_conocimiento.registrar(pos, base_conocimiento.CELDA_CONOCIDA)
			
			if valor == grid_manager.PERSONA:
				base_conocimiento.registrar(pos, base_conocimiento.PERSONA_DETECTADA)
				interfaz_agente.agregar_mensaje("Sensor detectó persona en " + str(pos))
			
			elif valor == grid_manager.PELIGRO:
				base_conocimiento.registrar(pos, base_conocimiento.PELIGRO)
				interfaz_agente.agregar_mensaje("Sensor detectó peligro en " + str(pos))
			
			elif valor == grid_manager.RECARGA:
				base_conocimiento.registrar(pos, base_conocimiento.RECARGA)
				interfaz_agente.agregar_mensaje("Sensor detectó recarga en " + str(pos))
			elif valor == grid_manager.PARED:
				interfaz_agente.agregar_mensaje("Sensor detectó pared en"+ str(pos))
