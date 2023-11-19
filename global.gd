extends Node

var state: State

signal play_click

func _ready() -> void:
	randomize()

func disconnect_signal(sig: Signal) -> void:
	for connection in sig.get_connections():
		sig.disconnect(connection.callable)

func play_click_sound() -> void:
	play_click.emit()
