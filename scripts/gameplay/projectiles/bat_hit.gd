extends Area2D

var state = 1
var damage = 50
export(float) var knockback = 100.0 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$spr.flip_v = state == 2
	$sounds/swing.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_bat_hit_body_entered(body):
	if body.has_method("enemy"):
		body.damage(damage)
		$sounds/swing.stop()
		$sounds/hit.play()
		body.knockback(knockback, global_position.direction_to(body.global_position))
	pass # Replace with function body.
