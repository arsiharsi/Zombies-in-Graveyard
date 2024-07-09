extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var start_pos = Vector2.ZERO
var zombie_scene = load("res://tscnes/mobs/zombie.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	play(str(int(rand_range(0, 3))))
	$start.start(rand_range(3, 20))
	start_pos = global_position
	pass # Replace with function body.

func shake(delta):
	global_position = start_pos+Vector2(rand_range(-delta,delta), rand_range(-delta,delta))
	pass

func spawn_zombie():
	var zombie = zombie_scene.instance()
	zombie.global_position = global_position
	zombie.enemy()
	GlobalSceneScript.main_node.add_child(zombie)
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_start_timeout():
	$def.play("def")
	pass # Replace with function body.
