extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$death.pitch_scale = rand_range(0.5, 1.5)
	randomize()
	play(str(int(rand_range(0, 3))))
	rotation_degrees = rand_range(-180,180)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
