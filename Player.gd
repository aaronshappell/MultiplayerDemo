extends KinematicBody2D

var speed: float = 700
var jump_speed: float = -1600
var gravity: float = 5500

var velocity := Vector2()
var jumping := false

puppet var puppet_pos := Vector2()


func _ready() -> void:
	if is_network_master():
		$Camera2D.make_current()


func _physics_process(delta: float) -> void:
	velocity.x = 0
	if is_network_master():
		if Input.is_action_pressed("ui_up") and is_on_floor():
			velocity.y = jump_speed
		if not Input.is_action_pressed("ui_up") and velocity.y < 0:
			velocity.y = lerp(velocity.y, 0, 0.2)
		if Input.is_action_pressed("ui_left"):
			velocity.x -= speed
		if Input.is_action_pressed("ui_right"):
			velocity.x += speed
		velocity.y += gravity * delta
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
