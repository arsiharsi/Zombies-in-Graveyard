extends Area2D

export(String, "bat", "pistol", "uzi", "shotgun") var weapon
var spr = {"bat":load("res://sprites/weapons/bases/bat.png"), "pistol":load("res://sprites/weapons/laying/pistol_laying.png"),
"uzi":load("res://sprites/weapons/laying/uzi_laying.png"), "shotgun":load("res://sprites/weapons/laying/shootgun_laying.png")}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$spr.rotation_degrees = rand_range(-180, 180)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pointer()
	$spr.texture = spr[weapon]
	pass


func _on_pickable_weapon_body_entered(body):
	if body.name == "player":
		if weapon == "bat":
			GlobalSceneScript.main_node.get_parent().start_game()
		body.weapons_enabled[weapon] = 1
		queue_free()
	pass # Replace with function body.


func pointer():
	$pointer_spr.global_position = GlobalSceneScript.player_position
	$pointer_spr.global_position += GlobalSceneScript.player_position.direction_to(
		global_position)*clamp(GlobalSceneScript.player_position.distance_to(global_position), 0, 105)
	$pointer_spr.look_at(global_position)
	pass
