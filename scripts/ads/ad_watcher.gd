extends Node

export var is_testing = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_interstitial_state_changed(state):
	if state == "loading" or state == "opened":
		get_tree().paused = true
	else:
		get_tree().paused = false

func rewarded_show():
	if is_testing:
		_on_rewarded_state_changed("rewarded")
	Bridge.advertisement.show_rewarded()
	pass


func interstitial_show():
	Bridge.advertisement.show_interstitial(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	Bridge.advertisement.connect("interstitial_state_changed", self, "_on_interstitial_state_changed")
	Bridge.advertisement.connect("rewarded_state_changed", self, "_on_rewarded_state_changed")
	pass # Replace with function body.


func _on_rewarded_state_changed(state):
	if state == "loading" or state == "opened":
		get_tree().paused = true
	elif state == "rewarded":
		GlobalSceneScript.main_node.get_parent().revive_succesful()
	else:
		get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
