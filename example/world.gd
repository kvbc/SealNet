extends Node2D

func _add_player(node: Node2D):
	node.global_position = Vector2(
		randf_range(-200.0, 200.0),
		randf_range(-200.0, 200.0)
	)
	add_child(node)

func _ready():
	if SealNet.is_client():
		_add_player(SealNet.instantiate_owner(preload("res://example/player.tscn")))
		SealNet.client_connected.connect(func(netid: int):
			#print("client ", netid)
			_add_player(SealNet.instantiate_owner(preload("res://example/player.tscn"), netid))
		)
		#_add_player(SealNet.instantiate_owner(preload("res://example/player.tscn"), 1))
	elif SealNet.is_server():
		_add_player(SealNet.instantiate_owner(preload("res://example/player.tscn")))
		SealNet.client_connected.connect(func(netid: int):
			#print("server ", netid)
			_add_player(SealNet.instantiate_owner(preload("res://example/player.tscn"), netid))
		)
