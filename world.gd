extends Node2D

var walls = []
var hole_size = 200
var hole_y_range = 300
var wall_distance = 500
var wall_spawn_x = 1200
var walls_passed = 0

@onready var actor = %Actor
@onready var wall_scene: Resource = preload("res://wall.tscn")
@onready var wall_counter = %WallCounter
@onready var game_over = %GameOver
@onready var wall_container = %WallContainer

func _ready():
	actor.player_died.connect(player_died)
	actor.game_started.connect(game_started)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var viewport_rect = get_viewport_rect()
	if !walls.is_empty():
		# despawn walls that are behind player and out of screen
		for wall in walls:
			if wall.global_position.x < actor.global_position.x - 300:
				walls.erase(wall)
				wall.queue_free()
				walls_passed += 1
				# update counter label
				wall_counter.text = "Du hast " + str(walls_passed) + " Hindernisse überwunden"
	else:
		spawn_wall(viewport_rect)
	# check if there need to be additional walls generated
	var needs_additional_wall = true
	for wall in walls:
		if wall.global_position.x > actor.global_position.x + wall_spawn_x - wall_distance:
			needs_additional_wall = false
	if needs_additional_wall:
		spawn_wall(viewport_rect)
	
func spawn_wall(viewport_rect: Rect2):
	var spawn_x = actor.global_position.x + wall_spawn_x
	var center = viewport_rect.get_center()
	var spawn_y = randf_range(center.y - hole_y_range, center.y + hole_y_range)
	var spawn1 = Vector2(spawn_x, spawn_y - hole_size)
	var spawn2 = Vector2(spawn_x, spawn_y + hole_size)
	var top_wall: Area2D = wall_scene.instantiate()
	var bottom_wall: Area2D = wall_scene.instantiate()
	top_wall.rotation_degrees = 180
	top_wall.global_position = spawn1
	bottom_wall.global_position = spawn2
	wall_container.add_child(top_wall)
	wall_container.add_child(bottom_wall)
	walls.append(top_wall)
	walls.append(bottom_wall)

func player_died():
	wall_counter.show()
	game_over.show()
	
func game_started():
	wall_counter.hide()
	game_over.hide()
