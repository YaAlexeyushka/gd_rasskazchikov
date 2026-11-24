class_name PlayerShip
extends Area2D

signal collided
signal destroyed

const MAX_SPEED := 260.0
const THROTTLE_RATE := 220.0
const TURN_SPEED := 3.5
const SHIELD_RECHARGE_TIME := 2.5

var speed := 0.0
var shield_active := true
var shield_recharge := 0.0

@onready var shield: Sprite2D = $Shield


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	var throttle := Input.get_axis("ui_down", "ui_up")
	speed = clampf(speed + throttle * THROTTLE_RATE * delta, 0.0, MAX_SPEED)
	rotation += Input.get_axis("ui_left", "ui_right") * TURN_SPEED * delta
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

	var screen := get_viewport_rect().size
	position = Vector2(fposmod(position.x, screen.x), fposmod(position.y, screen.y))

	if not shield_active and not has_overlapping_areas():
		shield_recharge += delta
		if shield_recharge >= SHIELD_RECHARGE_TIME:
			_restore_shield()


func respawn(at_position: Vector2) -> void:
	position = at_position
	rotation = 0.0
	speed = 0.0
	_restore_shield()


func _on_area_entered(_hazard: Area2D) -> void:
	collided.emit()
	shield_recharge = 0.0
	if shield_active:
		shield_active = false
		shield.hide()
	else:
		destroyed.emit()


func _restore_shield() -> void:
	shield_active = true
	shield_recharge = 0.0
	shield.show()
