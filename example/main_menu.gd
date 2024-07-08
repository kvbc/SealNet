extends CanvasLayer

@onready var host_port: LineEdit = %host_port
@onready var host_max_players: LineEdit = %host_max_players
@onready var host_button: Button = %host_button
@onready var join_port: LineEdit = %join_port
@onready var join_ip: LineEdit = %join_ip
@onready var join_button: Button = %join_button

func _ready():
	host_button.pressed.connect(func():
		SealNet.create_server(int(host_port.text), int(host_max_players.text))
		get_tree().change_scene_to_file("res://example/world.tscn")
	)
	join_button.pressed.connect(func():
		SealNet.create_client(join_ip.text, int(join_port.text))
		get_tree().change_scene_to_file("res://example/world.tscn")
	)
