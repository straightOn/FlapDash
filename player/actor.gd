extends CharacterBody2D

@onready var animation_player = %AnimationPlayer
@onready var label = %Label

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var started: bool = false
var speed: float = 300
var dash_speed: float = 1000
var jump_velocity: float = -500
var dive_velocity: float = 100

signal player_died
signal game_started

func _physics_process(delta):
	if !started:
		return
		
	velocity.y += gravity * delta
	velocity.x = lerp(velocity.x, speed, 0.1)

	if Input.is_action_just_pressed("ui_up") and started:
		velocity.y = jump_velocity
	if Input.is_action_just_pressed("ui_down") and started and velocity.y < dive_velocity:
		velocity.y = dive_velocity
	move_and_slide()

func _unhandled_input(event):
	if started && event.is_action_pressed("ui_right"):
		velocity.x = dash_speed
		velocity.y = 0
	if !started && event.is_action_pressed("ui_accept"):
		global_position.x = 200
		global_position.y = 400
		velocity.x = 0
		velocity.y = 0
		game_started.emit()
		started = true
		animation_player.play("fly")

func wall_crash():
	animation_player.play("dead")
	started=false
	player_died.emit()
