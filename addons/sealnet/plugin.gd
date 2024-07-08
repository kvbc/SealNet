@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("SealNet", "res://addons/sealnet/SealNet.gd")
