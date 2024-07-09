extends Sprite



var vec = Vector2.ZERO
var rotation_speed
export(float) var speed_drop_off = 3.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	rotation_speed = rand_range(-50,50)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(deg2rad(rotation_speed))
	global_position += vec*delta
	vec += (Vector2.ZERO - vec)/speed_drop_off
	if vec.length() < 3 and !$fall.playing:
		$fall.play()
	rotation_speed -= (0 - rotation_speed)/speed_drop_off/2
	if vec.length() <= 1:
		queue_free()
	pass
