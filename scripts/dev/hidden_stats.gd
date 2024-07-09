extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	visible = Input.is_action_pressed("SHOW_HIDDEN_STATS")
	$version.text = "Version: " + str(GlobalSceneScript.version)
	pass
