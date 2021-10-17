extends KinematicBody2D
#export variables - variables that can be edited in the inspector and are useful for testing values while playing the game
#Below are random values used to add to the game - I don't actually know if the physics for this is accurate, but it works lmao
export (int) var ACCELERATION = 500
export (int) var MAX_SPEED = 100
export (int) var GRAVITY = 200
export (int) var JUMP_FORCE = 120
export (float) var FRICTION = 0.25

var motion = Vector2.ZERO #a defined vector that will be used for movement, Vector2.ZERO is just (0,0)
var double_jump = true #a variable that checks if the player is allowed to double jump or not (since the player can't infinitely jump in the 
#onready var variables - called as soon as the whole script is ready, and is used in conjunction with $ to access the nodes found in the scene panel
onready var sprite = $Sprite 
onready var animationPlayer = $AnimationPlayer

#one of the main functions you use, this is a predefined godot function that basically runs the code constantly (there's a certain time interval like every frame, but idk it exactly)
func _physics_process(delta):
	motion.y += GRAVITY * delta #makes the player fall towards the ground
	#below is code that basically gets a number from your physical keyboard input. If you hit right, right = 1 and if you hit left hard, left = 1. Otherwise, they are just 0.
	#use print to demonstrate
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") 
	
	if x_input != 0: #if the right or left keys ARE being pressed
		animationPlayer.play("Run") #run animation plays
		sprite.flip_h = x_input < 0 #will flip the sprite according to the direction the keys are being pressed
		motion.x += x_input * ACCELERATION * delta #increases the movement vector horizontally by taking input (for direction), acceleration and delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED) #makes sure the movement never goes above the intended max speed
	else: #if the right or left keys are NOT being pressed
		animationPlayer.play("Idle") #idle animation plays
		motion.x = lerp(motion.x, 0, FRICTION) #player's movement slowly approaches towards 0, according to the FRICTION
	motion = move_and_slide(motion, Vector2.UP) #line of code that allows the motion vector to control the movement; without it, nothing can move
	
	if is_on_floor(): #returns true if there is a collision below the player
		if Input.is_action_just_pressed("ui_up"): #if the up arrow is tapped (doesn't need to be constantly pressed)
			motion.y = -JUMP_FORCE #is negative because y is flipped in Godot
		double_jump = true #resets the double_jump variable so the player can double jump again if they wish to
	else: #when the player is in the air
		animationPlayer.play("Jump") #jump animation plays
		if double_jump == true: #will check if the player is allowed to double jump
			if Input.is_action_just_pressed("ui_up"): #if player is allowed to double jump, is in the air, and pressed up again, it will jump once more
				motion.y = -JUMP_FORCE
				double_jump = false #set to false to prevent the player from jumping a third time, fourth time, or infinity times
		if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2: #allows for variable jumps; if the player releases the up arrow key while in midair and has not travelled super far, the jump cuts off and the player makes a smaller jump
			motion.y = -JUMP_FORCE
			
