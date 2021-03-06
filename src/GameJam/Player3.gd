#extends "res://PlayableChar.gd"
extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

const UP = Vector2(0, -1)
const GRAVITY = 10
const SPEED = 150
const JUMP_HEIGHT = -350

const ATKACID = preload("res://AtkScenes/AtkAcid.tscn")

var hp = 9 # starting
var max_hp = 9 # maximum
var is_ethereal = false # Makes player ethereal for some time

var motion = Vector2()

func _ready():
	$Camera2D/Healthbar._on_health_update(100)
	
func calculate_hp_perc(hp):
	return (100 * hp) / max_hp

func take_damage(dmg):
	$Camera2D/ScreenShake.shake()
	if not is_ethereal: # No damage if ethereal
		#is_ethereal = true 
		hp -= dmg
		$Camera2D/Healthbar._on_health_update(calculate_hp_perc(hp))
		if hp <= 0 :
			#print("Dead")
			die()

func die():
	#print("Dead")
	$CollisionShape2D.disabled = true
	get_tree().change_scene("res://GameOver.tscn")
	 

func _physics_process(delta):
	
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = SPEED
		$Sprite.flip_h = false  #Acess to sprite
		$Sprite.play("Run")
		if sign($Position2D.position.x) == -1: #Handles attack side changes
			$Position2D.position.x *= -1
	elif Input.is_action_pressed("ui_left"):
		motion.x = -SPEED
		$Sprite.flip_h = true
		$Sprite.play("Run") #CHANGE LATER: JUST MOVE LEGS
		if sign($Position2D.position.x) == 1: #Handles attack side changes
			$Position2D.position.x *= -1
	else:
		motion.x = 0
		$Sprite.play("Idle")
		
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
		#else:
		#	$Sprite.play("Run") #CHANGE LATER #Maybe not...
	
	
	
	if Input.is_action_just_pressed("ui_focus_next"): #tab
		var acid = ATKACID.instance()
		
		if sign($Position2D.position.x) == 1: #Define attack main position
			acid.set_atk_direction(1)
		else:
			acid.set_atk_direction(-1)
		
		get_parent().add_child(acid)
		acid.position = $Position2D.global_position
	
	motion = move_and_slide(motion, UP)
	
	#Damage and death
	if get_slide_count() > 0 :
		for i in range(get_slide_count()):
			if "Enemy" in get_slide_collision(i).collider.name:
				#print("Collided")
				take_damage(1)
				#$Timer.start()
				
		
	pass

func _on_Timer_timeout():
	is_ethereal = false #disables ethereal
	pass # Replace with function body.
