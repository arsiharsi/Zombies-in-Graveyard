extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rotation_speed = 0
var vec = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	play(str(int(rand_range(0, 3))))
	vec.x = rand_range(-100, 100)
	vec.y = rand_range(-100, 100)
	rotation_speed = rand_range(-45,45)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position+=vec*delta
	rotate(deg2rad(rotation_speed))
	vec += (Vector2.ZERO-vec)/10
	rotation_speed -= rotation_speed/10
	scale.x = vec.length()/20
	scale.y = vec.length()/20
	if vec.length() <= 1:
		queue_free()
	pass
