extends CharacterBody3D

var movement_input: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	movement_input = Vector2.ZERO
	if event.is_action("move_forward"):
		movement_input += Vector2.UP
	if event.is_action("move_backwards"):
		movement_input += Vector2.DOWN
	if event.is_action("move_left"):
		movement_input += Vector2.LEFT
	if event.is_action("move_right"):
		movement_input += Vector2.RIGHT
		
	movement_input = movement_input.normalized()

func _physics_process(delta: float) -> void:
	velocity = velocity.slerp(Vector3(movement_input.x, 0, movement_input.y) * 5 + get_gravity(), delta)
	move_and_slide()
	
