extends Node

func _ready():
	SealNet.action_client_callback.connect(func(action_name: String, args: Dictionary, action_state: SealNet.ClientActionState, node: Node):
		match action_name:
			"player_correct":
				if action_state == SealNet.ClientActionState.Success:
					node = node as Player
					node.correct(args.server_position, args.server_velocity)
			"player_move":
				if action_state == SealNet.ClientActionState.Simulate:
					node = node as Player
					node.move_in_direction(args.direction)
	)
	
	if SealNet.is_server():
		SealNet.action_server_callback.connect(func(action_name: String, args: Dictionary, node: Node):
			match action_name:
				"player_correct":
					node = node as Player
					args.server_position = node.global_position
					args.server_velocity = node.velocity
					SealNet.send_action_server_response(true)
				"player_move":
					node = node as Player
					node.move_in_direction(args.direction)
					SealNet.send_action_server_response(true)
		)
		
func start_correcting_player(player: Player) -> void:
	if SealNet.is_server():
		SealNet.network_process.connect(func():
			SealNet.send_action("player_correct", {}, player)
		)
		
func move_player(player: Player, direction: Vector2) -> void:
	if SealNet.is_owner(player):
		SealNet.send_action("player_move", {"direction" = direction}, player)
