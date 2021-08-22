extends KinematicBody2D

export var move_speed: float = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var velocity := Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	velocity = velocity.normalized() * move_speed
	velocity = move_and_slide(velocity, Vector2.UP)