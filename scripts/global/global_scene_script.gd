extends Node

var main_node
var player_position = Vector2.ZERO
var score = 0
var highscore = 0
var money = 0
var combo = 0
var version = 6
# Declare member variables here. Examples:
# var a = 2
# var b = "text"



func reset_game():
	combo = 0
	score = 0

func _on_storage_get_completed(success, data):
	if success:
		if data != null:
			print(data)
			highscore = int(data)
		else:
			print("Data is null")
			highscore = 0



func _on_storage_set_completed(success):
	print("On Storage Set Completed, success: ", success)



func save():
	Bridge.storage.set("highscore",str(highscore), funcref(self, "_on_storage_set_completed"))
	pass



func load_save():
	Bridge.storage.get("highscore", funcref(self, "_on_storage_get_completed"))



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
