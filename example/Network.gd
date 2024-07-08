extends Node

func _ready():
	SealNet.action_client_callback.connect(func(action_name: String, args: Dictionary, action_state: SealNet.ClientActionState, node: Node):
		match action_name:
			"player_update":
				if action_state == SealNet.ClientActionState.Success:
					node = node as Player
					node.correct_position(args.server_position)
			"player_move":
				node = node as Player
				node.move_in_direction(args.direction)
	)
	
	if SealNet.is_server():
		SealNet.action_server_callback.connect(func(action_name: String, args: Dictionary, node: Node):
			match action_name:
				"player_update":
					node = node as Player
					args.server_position = node.global_position
					SealNet.send_action_server_response(true)
				"player_move":
					node = node as Player
					node.move_in_direction(args.direction)
					SealNet.send_action_server_response(true)
		)
		
func update_player_position(player: Player) -> void:
	if SealNet.is_server():
		SealNet.send_action("player_update", {}, player)
		
func move_player(player: Player, direction: Vector2) -> void:
	if SealNet.is_owner(player):
		SealNet.send_action("player_move", {"direction" = direction}, player)
