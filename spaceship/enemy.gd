class_name EnemyShip
extends Area2D

const MAX_SPEED := 130.0
const CRUISE_SPEED := 66.0
const ACCELERATION := 175.0
const TURN_SPEED := 4.0
const DETECTION_RADIUS := 450.0
const SLOWDOWN_RADIUS := 120.0
const NEIGHBOR_RADIUS := 120.0
const SEPARATION_RADIUS := 54.0
const ORBIT_SPEED := 1.15

@export var orbit_radius := 142.0

var target: Node2D
var orbits := false
var velocity := Vector2.ZERO
var orbit_angle := 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if orbits:
		sprite.scale *= 1.45
		sprite.modulate = Color(1.28, 2.1, 0.75)
		var collision_shape: CollisionShape2D = $CollisionShape2D
		var orbit_shape := CircleShape2D.new()
		orbit_shape.radius = 17.0
		collision_shape.shape = orbit_shape
		if is_instance_valid(target):
			orbit_angle = (global_position - target.global_position).angle()
			move_in_orbit(0.0)
	else:
		add_to_group(&"enemy_flock")
		rotation = randf_range(-PI, PI)
		velocity = Vector2.from_angle(rotation) * CRUISE_SPEED


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	if orbits:
		move_in_orbit(delta)
	else:
		move_with_flock(delta)


func move_in_orbit(delta: float) -> void:
	orbit_angle = wrapf(orbit_angle + ORBIT_SPEED * delta, 0.0, TAU)
	global_position = target.global_position + Vector2.from_angle(orbit_angle) * orbit_radius
	rotation = orbit_angle + PI / 2.0


func move_with_flock(delta: float) -> void:
	var desired_velocity := velocity.normalized() * CRUISE_SPEED
	var to_target := target.global_position - global_position
	var target_distance := to_target.length()
	if target_distance < DETECTION_RADIUS:
		var speed := MAX_SPEED * minf(target_distance / SLOWDOWN_RADIUS, 1.0)
		desired_velocity = to_target.normalized() * speed

	desired_velocity += flock_steering()
	var steering := (desired_velocity - velocity).limit_length(ACCELERATION * delta)
	velocity = (velocity + steering).limit_length(MAX_SPEED)
	position += velocity * delta

	var screen_size := get_viewport_rect().size
	position.x = wrapf(position.x, 0.0, screen_size.x)
	position.y = wrapf(position.y, 0.0, screen_size.y)
	if velocity.length_squared() > 1.0:
		rotation = rotate_toward(rotation, velocity.angle(), TURN_SPEED * delta)


func flock_steering() -> Vector2:
	var separation := Vector2.ZERO
	var center := Vector2.ZERO
	var average_velocity := Vector2.ZERO
	var neighbor_count := 0

	for node in get_tree().get_nodes_in_group(&"enemy_flock"):
		var neighbor := node as EnemyShip
		if neighbor == self:
			continue
		var offset := neighbor.global_position - global_position
		var distance := offset.length()
		if distance >= NEIGHBOR_RADIUS:
			continue
		center += neighbor.global_position
		average_velocity += neighbor.velocity
		neighbor_count += 1
		if distance < SEPARATION_RADIUS:
			separation -= offset.normalized() * (1.0 - distance / SEPARATION_RADIUS)

	if neighbor_count == 0:
		return Vector2.ZERO
	var cohesion := (center / neighbor_count - global_position) * 0.4
	var alignment := (average_velocity / neighbor_count - velocity) * 0.16
	return separation * 120.0 + alignment + cohesion
