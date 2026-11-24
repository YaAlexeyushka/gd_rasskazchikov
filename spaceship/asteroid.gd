extends Area2D

var drift := Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += drift * delta
	position = position.posmodv(get_viewport_rect().size)
	rotation += 0.4 * delta
