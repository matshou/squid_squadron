extends Area2D

signal hit

# how fast the player will move (pixels/sec)
export (int) var MAX_SPEED = 250
export (int) var ACCELERATION = 25
export (int) var FRICTION = 7

var velocity = Velocity.new(self)
var screensize  # size of the game window

onready var debug = get_node("../Debug")

class Velocity:
	# Use this instance to reach player variables
	var player
	
	func _init(var owner):
		player = owner
	
	enum { AXIS_X, AXIS_Y }
	
	# Constant variables, DON'T ALTER VALUES!
	var north = Direction.new("ui_up", AXIS_Y, -1) setget privateSet
	var south = Direction.new("ui_down", AXIS_Y, 1) setget privateSet
	var east = Direction.new("ui_right", AXIS_X, 1) setget privateSet
	var west = Direction.new("ui_left", AXIS_X, -1) setget privateSet
	
	func privateSet():
		print("Error: Access to private variable!")
		print_stack()
		pass
	
	class Direction:
		var key
		var axis
		var value
		
		func _init(var k, var a, var v):
			key = k
			axis =a
			value =v

	var motion_vector = Vector2()
	var input_vector = Vector2()
	var move_vector = Vector2()
	# used for printing debug info
	var key_pressed = [ null, null ]
	
	func resetKeyPressed(var axis):
		key_pressed[axis] = null
	
	func resetInputVector():
		input_vector = Vector2()
	
	func setInputVector(var direction):
		match direction.axis:
			AXIS_X:
				input_vector.x = direction.value
				key_pressed[AXIS_X] = direction
			AXIS_Y:
				input_vector.y = direction.value
				key_pressed[AXIS_Y] = direction
	
	func move(var delta):
		applyFriction()
		move_vector = input_vector + motion_vector
		#if (move_vector.x == move_vector.y):
		#	move_vector = move_vector.x * sqrt(2)
		#else: sqrt(pow(move_vector.x, 2) + pow(move_vector.y, 2))
			
		# Clamp the player position to prevent him from leaving the screen
		player.position += move_vector * delta
		player.position.x = clamp(player.position.x, 0, player.screensize.x)
		player.position.y = clamp(player.position.y, 0, player.screensize.y)
		
		printDebug()
		
	func accelerate(var direction):
		match direction.axis:
			AXIS_Y:
				motion_vector.y += (player.ACCELERATION * direction.value)
				if (abs(motion_vector.y) > player.MAX_SPEED):
					motion_vector.y = player.MAX_SPEED if (motion_vector.y > 0) else -player.MAX_SPEED
					
			AXIS_X:
				motion_vector.x += (player.ACCELERATION * direction.value)
				if (abs(motion_vector.x) > player.MAX_SPEED):
					motion_vector.x = player.MAX_SPEED if (motion_vector.x > 0) else -player.MAX_SPEED
	
	func applyFriction():
		var f_vec = Vector2(0, 0)
		
		if (motion_vector.x > 0):
			var res = motion_vector.x - player.FRICTION
			f_vec.x = -player.FRICTION if (res > 0) else -motion_vector.x
		elif (motion_vector.x < 0):
			var res = motion_vector.x + player.FRICTION
			f_vec.x = player.FRICTION if (res < 0) else -motion_vector.x
		
		if (motion_vector.y > 0):
			var res = motion_vector.y - player.FRICTION
			f_vec.y = -player.FRICTION if (res > 0) else -motion_vector.y
		elif (motion_vector.y < 0):
			var res = motion_vector.y + player.FRICTION
			f_vec.y = player.FRICTION if (res < 0) else -motion_vector.y
			
		motion_vector += f_vec
		
	# Update velocity information in the debug panel
	func printDebug():
		player.debug.updateVectorInfo(move_vector)
		player.debug.updateMotionInfo(motion_vector)
		player.debug.updatePositionInfo(player.position)
		player.debug.updateInputInfo(key_pressed)

func hasMomentum():
	return (velocity.motion_vector.length() > 0)

func start(pos):
	position = pos 
	show()
	$CollisionShape2D.disabled = false

func _ready():
	hide()
	screensize = get_viewport_rect().size

#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
func _process(delta):
	
	velocity.resetInputVector()
	
	if Input.is_action_pressed(velocity.east.key):
		velocity.setInputVector(velocity.east)
		velocity.accelerate(velocity.east)
	elif Input.is_action_pressed(velocity.west.key):
		velocity.setInputVector(velocity.west)
		velocity.accelerate(velocity.west)
	else: velocity.resetKeyPressed(Velocity.AXIS_X)
	
	if Input.is_action_pressed(velocity.south.key):
		velocity.setInputVector(velocity.south)
		velocity.accelerate(velocity.south)
	elif Input.is_action_pressed(velocity.north.key):
		velocity.setInputVector(velocity.north)
		velocity.accelerate(velocity.north)
	else: velocity.resetKeyPressed(Velocity.AXIS_Y)
		
	if (hasMomentum()):
		velocity.move(delta)
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	
	if velocity.move_vector.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.move_vector.x < 0
	elif velocity.move_vector.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.move_vector.y > 0

func _on_Player_body_entered(body):
	hide() # Player disappears after being hit
	emit_signal("hit")
	$CollisionShape2D.disabled = true
