extends Node

var energia := 100
var energia_max := 100
var costo_movimiento := 4

func consumir_movimiento():
	energia -= costo_movimiento
	energia = clamp(energia, 0, energia_max)

func consumir_danio(cantidad: int):
	energia -= cantidad
	energia = clamp(energia, 0, energia_max)

func recargar():
	energia = energia_max

func tiene_energia_suficiente(costo: int) -> bool:
	return energia >= costo
