class_name knowledgeBase
extends RefCounted

var memoria_peligro := {}
var base_conocimiento := {}

func registrar(pos: Vector2i, tipo: String):
	base_conocimiento[pos] = tipo

func agregar_penalizacion(pos: Vector2i, valor: int):
	memoria_peligro[pos] = memoria_peligro.get(pos, 0) + valor

func contar_por_tipo(tipo: String) -> int:
	return base_conocimiento.values().count(tipo)
