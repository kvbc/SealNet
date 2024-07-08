#
# Client sends an action:
# - client simulates the action locally
# - client sends the action to the server
# - the server validates the action 
#   -> success:
#      - server processes and distributes the action forward to all other clients
#   -> failure:
#      - server tells the client that the action has failed
#      - client rollbacks the local simulation (optional)
#      - client resends the action (optional)
#

extends Node

signal client_connected(netid: int)
signal network_process
signal action_client_callback(action_name: String, args: Dictionary, action_state: ClientActionState, node: Node)
signal action_server_callback(action_name: String, args: Dictionary, node: Node)
signal _action_server_responded(success: bool)

const DEFAULT_PORT := 42069
const DEFAULT_MAX_CLIENTS := 32
const NETWORK_PROCESS_FPS := 30

enum ClientActionState {
	None,
	Simulate,
	Success,
	Fail
}

func _ready():
	var net_process_timer := Timer.new()
	net_process_timer.wait_time = 1.0 / NETWORK_PROCESS_FPS
	net_process_timer.autostart = true
	net_process_timer.timeout.connect(func():
		network_process.emit()
	)
	add_child(net_process_timer)

func _connect_signals(peer: ENetMultiplayerPeer) -> void:
	peer.peer_connected.connect(func(netid: int):
		client_connected.emit(netid)
	)

func create_client(ip: String, port := DEFAULT_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	_connect_signals(peer)
	multiplayer.multiplayer_peer = peer

func create_server(port := DEFAULT_PORT, max_clients := DEFAULT_MAX_CLIENTS) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port, max_clients)
	_connect_signals(peer)
	multiplayer.multiplayer_peer = peer
	
func is_client      ()           -> bool: return not is_server()
func is_server      ()           -> bool: return multiplayer.is_server()
func get_owner_netid(node: Node) -> int:  return node.get_meta("owner_netid", -1)
func is_owner       (node: Node) -> bool: return get_owner_netid(node) == get_netid()
func get_netid      ()           -> int:  return multiplayer.multiplayer_peer.get_unique_id()
	
func send_action(action_name: String, args := {}, node: Node = null) -> void:
	var node_path := node.get_path() if node else ""
	if is_client():
		_send_action(action_name, args, node_path, ClientActionState.Simulate)
		_send_action.rpc_id(1, action_name, args, node_path)
	else: # server
		_send_action(action_name, args, node_path)

func send_action_server_response(success: bool) -> void:
	_action_server_responded.emit(success)

@rpc("any_peer", "reliable")
func _send_action(
	action_name: String,
	args: Dictionary,
	node_path: NodePath,
	client_action_state := ClientActionState.None,
) -> void:
	var node: Node = get_node_or_null(node_path)
	if is_server():
		action_server_callback.emit(action_name, args, node)
		var success: bool = await _action_server_responded
		_send_action.rpc(
			action_name, args, node_path,
			ClientActionState.Success if success else ClientActionState.Fail
		)
	else: # client
		action_client_callback.emit(action_name, args, client_action_state, node)

func instantiate_owner(packed_scene: PackedScene, owner_netid: int = get_netid()) -> Node:
	var node := packed_scene.instantiate()
	node.set_meta("owner_netid", owner_netid)
	return node
