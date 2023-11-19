extends Node

var state: State

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	pass

func disconnect_signal(sig: Signal) -> void:
	for connection in sig.get_connections():
		sig.disconnect(connection.callable)
