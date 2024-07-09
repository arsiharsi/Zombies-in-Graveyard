extends Area2D

export(float) var speed = 50.0
export(int) var damage = 50
export(int) var penetration = 1
export(float) var knockback = 100.0 
var vec = Vector2.ZERO
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	global_position += vec*speed*delta
	rotation = vec.angle()
	pass


func _on_bullet_body_entered(body):
	penetration -= 1
	if penetration <= 0:
		queue_free()
	if body.has_method("enemy"):
		body.damage(damage)
		body.knockback(knockback, global_position.direction_to(body.global_position))
	pass # Replace with function body.


func _on_end_timeout():
	queue_free()
	pass # Replace with function body.


func _on_vis_screen_exited():
	queue_free()
	pass # Replace with function body.
