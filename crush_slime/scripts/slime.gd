class_name Slime
extends StaticBody2D

@export var tint := Color.WHITE

var crushed := false

@onready var visual: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	visual.modulate = tint


func crush() -> void:
	if crushed:
		return
	crushed = true
	collision_shape.set_deferred("disabled", true)
	var squash := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	squash.tween_property(visual, "scale", Vector2(1.5, 0.34), 0.16)
