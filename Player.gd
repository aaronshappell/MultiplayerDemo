extends KinematicBody2D

export var move_speed: float = 200

puppet var puppet_pos := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_network_master():
		$Camera2D.make_current()

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var velocity := Vector2()
	
	if is_network_master():
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		velocity = velocity.normalized() * move_speed
		rpc_unreliable("update_player", position)
	else:
		position = puppet_pos
	
	velocity = move_and_slide(velocity, Vector2.UP)
	if not is_network_master():
		puppet_pos = position


func set_player_name(name: String) -> void:
	$Name.text = name


puppet func update_player(pos: Vector2) -> void:
	puppet_pos = pos
