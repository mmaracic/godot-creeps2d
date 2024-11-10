extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@onready var screen_size = get_viewport_rect().size # Size of the game window.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_v = false
			# See the note below about the following boolean assignment.
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "up"
			$AnimatedSprite2D.flip_v = velocity.y > 0
		velocity = velocity.normalized() * speed
		# $ is shorthand for get_node(). So in the code below, $AnimatedSprite2D.play()
		# is the same as get_node("AnimatedSprite2D").play()
		# In GDScript, $ returns the node at the relative path from the current node,
		# or returns null if the node is not found.
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func start(pos: Vector2) -> void:
	position = pos
	show()
	#disabled setting not deferred here
	$CollisionShape2D.disabled = false
	
func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	# Disabling the area's collision shape can cause an error if it happens
	# in the middle of the engine's collision processing.
	# Using set_deferred() tells Godot to wait to disable the shape until it's safe to do so.
	$CollisionShape2D.set_deferred("disabled", true)
