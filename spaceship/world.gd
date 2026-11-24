extends Node2D

const ENEMY_COUNT := 10
const SHIP_START := Vector2(512, 384)
const ENEMY_SCENE := preload("res://enemy.tscn")
const ASTEROID_SCENE := preload("res://asteroid.tscn")

var lifetime := 0.0

@onready var ship: PlayerShip = $Ship
@onready var enemies: Node2D = $Enemies
@onready var asteroids: Node2D = $Asteroids
@onready var orbit_guide: Line2D = $OrbitGuide
@onready var lifetime_label: Label = $HUD/TimerPanel/Margin/VBox/Lifetime
@onready var shield_label: Label = $HUD/TimerPanel/Margin/VBox/ShieldStatus
@onready var enemy_label: Label = $HUD/EnemyPanel/Margin/VBox/EnemyCount


func _ready() -> void:
	ship.collided.connect(_reset_lifetime)
	ship.destroyed.connect(_respawn_ship, CONNECT_DEFERRED)
	ship.respawn(SHIP_START)

	for index in ENEMY_COUNT:
		var enemy: EnemyShip = ENEMY_SCENE.instantiate()
		var angle := TAU * float(index) / ENEMY_COUNT - PI / 3.0
		enemy.target = ship
		enemy.orbits = index == 0
		enemy.position = SHIP_START + Vector2.from_angle(angle) * (240.0 + 42.0 * (index % 2))
		enemies.add_child(enemy)
		if enemy.orbits:
			for point in 64:
				orbit_guide.add_point(Vector2.from_angle(TAU * float(point) / 64.0) * enemy.orbit_radius)

	enemy_label.text = "Враги  %d" % enemies.get_child_count()
	_add_asteroid(Vector2(210, 170), Vector2(46, 36))
	_add_asteroid(Vector2(806, 600), Vector2(-44, -34))
	$AsteroidTimer.timeout.connect(_spawn_asteroid)


func _physics_process(delta: float) -> void:
	if ship.has_overlapping_areas():
		lifetime = 0.0
	else:
		lifetime += delta


func _process(_delta: float) -> void:
	orbit_guide.position = ship.position
	lifetime_label.text = "%.1f с" % lifetime
	if ship.has_overlapping_areas():
		shield_label.text = "Столкновение"
	elif ship.shield_active:
		shield_label.text = "Щит активен"
	else:
		shield_label.text = "Щит восстанавливается"


func _reset_lifetime() -> void:
	lifetime = 0.0
	lifetime_label.text = "0.0 с"


func _respawn_ship() -> void:
	ship.respawn(SHIP_START)


func _spawn_asteroid() -> void:
	var field := get_viewport_rect().size
	var spawn_position := Vector2(randf_range(0.0, field.x), 0.0)
	var target := Vector2(randf_range(0.2, 0.8) * field.x, field.y * 0.5)
	_add_asteroid(spawn_position, spawn_position.direction_to(target) * randf_range(36.0, 60.0))


func _add_asteroid(spawn_position: Vector2, drift: Vector2) -> void:
	var asteroid: Area2D = ASTEROID_SCENE.instantiate()
	asteroid.position = spawn_position
	asteroid.drift = drift
	asteroids.add_child(asteroid)
