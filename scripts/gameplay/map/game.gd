extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var en_logo = load("res://sprites/menu/localization/en.png")
var ru_logo = load("res://sprites/menu/localization/ru.png")
var difficulty = 1.0
var player_speed_vec = Vector2.ZERO
var player_last_position = Vector2.ZERO
var grave_scene = load("res://tscnes/mobs/grave.tscn")
var zombies_scene = load("res://tscnes/mobs/zombie.tscn")

# Called when the node enters the scene tree for the first time.

func _on_visibility_state_changed(state):
	# visible, hidden
	AudioServer.set_bus_mute(0, state == "hidden")


func _ready():
	
	Bridge.game.connect("visibility_state_changed", self, "_on_visibility_state_changed")
	GlobalSceneScript.load_save()
	TranslationServer.set_locale(Bridge.platform.language)
	GlobalSceneScript.score = 0
	GlobalSceneScript.money = 100000
	randomize()
	GlobalSceneScript.main_node = $game
	Bridge.platform.send_message("game_ready")
	pass # Replace with function body.

var mouse_hidden = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("mouse_hide_show"):
		if not mouse_hidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			mouse_hidden = true
		else: 
			mouse_hidden = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$sounds/music.stream_paused = $game/player.alive == false
	if TranslationServer.get_locale() == "ru":
		$fg/localization/button.normal = ru_logo
	else:
		$fg/localization/button.normal = en_logo
	$timers/spawn_timer.wait_time = 10-difficulty
	$fg/menu/max_score.text = tr("MAX_SCORE")+": "+str(GlobalSceneScript.highscore)
	player_speed_vec = GlobalSceneScript.player_position - player_last_position
	player_last_position = GlobalSceneScript.player_position
	pass


func start_game():
	$timers/spawn_timer.start()
	$anims/start.play("start")
	$timers/add_dificulty_timer.start()


func spawn_grave():
	var dist = rand_range(600, 800)
	var z_position = GlobalSceneScript.player_position.direction_to(GlobalSceneScript.player_position +
	 player_speed_vec + Vector2(rand_range(-1,1),rand_range(-1,1)))*dist
	var grave = grave_scene.instance()
	grave.global_position = GlobalSceneScript.player_position + z_position
	$graves.add_child(grave)
	if difficulty > 5:
		spawn_zombie(grave.global_position)


func spawn_zombie(pos):
	var zombie = zombies_scene.instance()
	zombie.global_position = pos
	$game.add_child(zombie)
	pass


func _on_spawn_timer_timeout():
	spawn_grave()
	print(str(10-difficulty)+" "+str($graves.get_child_count()))
	$timers/spawn_timer.start(10-difficulty)
	pass # Replace with function body.


func _on_add_dificulty_timer_timeout():
	difficulty += 0.1
	print("dif: "+str(difficulty))
	print("time: "+str(10-difficulty))
	difficulty = clamp(difficulty, 0, 9.99)
	pass # Replace with function body.


func _on_localization_button_pressed():
	if TranslationServer.get_locale() == "ru":
		TranslationServer.set_locale("en")
	else:
		TranslationServer.set_locale("ru")
	pass # Replace with function body.



func gameover():
	if GlobalSceneScript.score > GlobalSceneScript.highscore:
		$fg/screen_cover/death/new_highscore.show()
		GlobalSceneScript.highscore = GlobalSceneScript.score
		GlobalSceneScript.save()
	$anims/end.play("def")



func full_restart():
	get_tree().change_scene("res://tscnes/gameplay/game.tscn")


func _on_restart_pressed():
	$ad_watcher.interstitial_show()
	$anims/end.play("back_to_start")
	pass # Replace with function body.


func _on_revive_pressed():
	$ad_watcher.rewarded_show()
	pass # Replace with function body.


func revive_succesful():
	$anims/end.play("revive")
	$game/player.revive_player()
	pass
