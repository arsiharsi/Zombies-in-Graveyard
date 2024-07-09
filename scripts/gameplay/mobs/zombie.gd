extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var vec = Vector2.ZERO
export var lives = 100
export var max_speed = 175.0
export var add_speed = 10.0
var actual_speed = 0.0
var gl_delta = 0
var b_drop = load("res://tscnes/gameplay/misc/blood_drop.tscn")
var b_stain = load("res://tscnes/gameplay/misc/blood_stain.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.


func enemy():
	lives = rand_range(lives/1.5, lives*1.25*GlobalSceneScript.main_node.get_parent().difficulty)
	max_speed = max_speed*(100/lives)
	var rand_max = bool(int(rand_range(0, 2)))
	if rand_max:
		max_speed = 185
	$coll.scale.x = lives/100
	$coll.scale.y = lives/100
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$coll/spr.look_at(GlobalSceneScript.player_position)
	$def.pitch_scale = rand_range(0.5, 1.5)
	gl_delta = delta
	actual_speed += add_speed*delta
	actual_speed = clamp(actual_speed,-max_speed*20,max_speed)
	vec = global_position.direction_to(GlobalSceneScript.player_position)*actual_speed
	vec = move_and_slide(vec)
	pass


func knockback(force, dir):
	vec += dir
	actual_speed = -force
	pass


func damage(dmg):
	$damage.pitch_scale = rand_range(0.5, 1.5)
	$damage.play()
	lives -= dmg
	GlobalSceneScript.score += dmg *GlobalSceneScript.combo
	var blood = b_drop.instance()
	blood.global_position = global_position
	GlobalSceneScript.main_node.add_child(blood)
	if lives <= 0:
		GlobalSceneScript.combo += 1
		GlobalSceneScript.money += 10*GlobalSceneScript.combo/2
		var stain = b_stain.instance()
		stain.global_position = global_position
		GlobalSceneScript.main_node.get_node("../bg").add_child(stain)
		queue_free()


func _on_damager_body_entered(body):
	if body.name == "player":
		if GlobalSceneScript.combo >= 50:
			GlobalSceneScript.combo = 0
		elif body.alive == true:
			GlobalSceneScript.combo = 0
			body.kill_player()
	pass # Replace with function body.


func _on_def_finished():
	$def.pitch_scale = rand_range(0.5, 1.5)
	$def.play()
	pass # Replace with function body.
