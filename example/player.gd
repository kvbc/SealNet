class_name Player extends CharacterBody2D

const ACCELL = 1500.0
const DEACCELL = 1000.0

func move_in_direction(direction: Vector2):
	velocity += direction * ACCELL * 1.0 / Engine.physics_ticks_per_second

func correct_position(target_position: Vector2):
	global_position = target_position

func _ready():
	name = str(SealNet.get_owner_netid(self))
	$Label.text = name
	
	if SealNet.is_owner(self):
		add_child(Camera2D.new())
		
	SealNet.network_process.connect(func():
		Network.update_player_position(self)
	)

func _physics_process(delta):
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if not direction.is_zero_approx():
		Network.move_player(self, direction)
	velocity = velocity.move_toward(Vector2.ZERO, DEACCELL * delta)
	move_and_slide()
