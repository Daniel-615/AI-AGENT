extends Node

var memoria_peligro := {}
var conocimientos := {}

const PERSONA_RESCATADA := "persona_rescatada"
const PELIGRO := "zona_peligrosa"
const RECARGA := "estacion_recarga"
const PERSONA_DETECTADA := "persona_detectada"
const CELDA_CONOCIDA := "celda_conocida"

func registrar(pos: Vector2i, tipo: String):
	conocimientos[pos] = tipo

func contar(tipo: String) -> int:
	var total := 0
	
	for posicion in conocimientos.keys():
		if conocimientos[posicion] == tipo:
			total += 1
	
	return total

func aprender_peligro(pos: Vector2i, cantidad: int):
	memoria_peligro[pos] = memoria_peligro.get(pos, 0) + cantidad

func obtener_memoria_peligro() -> Dictionary:
	return memoria_peligro

func obtener_posiciones_por_tipo(tipo: String) -> Array:
	var posiciones := []
	
	for pos in conocimientos.keys():
		if conocimientos[pos] == tipo:
			posiciones.append(pos)
	
	return posiciones
