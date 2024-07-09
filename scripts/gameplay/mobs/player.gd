extends KinematicBody2D




var pickable_weapon_tscn = load("res://tscnes/gameplay/pickable/pickable_weapon.tscn")
export(bool) var is_shop = false
export(float) var speed = 1000.0
export(float) var run_speed_ad = 5000.0
var vec = Vector2.ZERO
# BAT
var bat_hit_scene = load("res://tscnes/gameplay/projectiles/bat_hit.tscn")
var is_able_bat = true
var bat_state = 1
export var bat_shoot_cd = 1.0
export var bat_damage = 50
var current_weapon = -1
# BAT END
# PISTOL
var pistol_unlocked = true
var pistol_bullet_scene = load("res://tscnes/gameplay/projectiles/bullet.tscn")
var bullet_shell_scene = load("res://tscnes/gameplay/projectiles/bullet_shell.tscn")
var is_able_to_shoot_pistol = true
export var pistol_max_ammo = 12
export var pistol_shoot_cd = 0.1
export var pistol_reload_cd = 5.0
export var pistol_spread = 30.0
export var pistol_damage = 50
export var pistol_penetration = 1
var pistol_current_ammo = 12
# PISTOL END
# UZI
var uzi_unlocked = true
var is_able_to_shoot_uzi = true
export var uzi_max_ammo = 30
export var uzi_shoot_cd = 0.05
export var uzi_reload_cd = 5.0
export var uzi_spread = 45.0
export var uzi_damage = 50
export var uzi_penetration = 1
var uzi_current_ammo = 30
# UZI_END
# SHOTGUN
var shotgun_unlocked = true
var shotgun_bullet_scene = load("res://tscnes/gameplay/projectiles/pellet.tscn")
var shotgun_shell_scene = load("res://tscnes/gameplay/projectiles/shotgun_shell.tscn")
var is_able_to_shoot_shotgun = true
export var shotgun_max_ammo = 6
export var shotgun_shoot_cd = 1.0
export var shotgun_reload_cd = 2.0
export var shotgun_spread = 60.0
export var shotgun_damage = 30
export var shotgun_penetration = 1
export var shotgun_pelets = 6
var shotgun_current_ammo = 6
var alive = true
# SHOTGUN END
var weapons_enabled = {"bat":0,"pistol":0,"uzi":0,"shotgun":0}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var walk_check = false
var pick_check = false
var shop_check = false
var reload_check = false
var ranking_check = false

func controls_check():
	if not walk_check:
		walk_check = vec.length() != 0
		if walk_check:
			$controls/walk/def.play("end")
	if not pick_check and weapons_enabled["bat"] == 1:
		if !$controls/picking_weapons/def.is_playing():
			$controls/picking_weapons/def.play("start")
		if current_weapon == 0:
			$controls/picking_weapons/def.play("end")
			pick_check = true
	if not shop_check:
		if GlobalSceneScript.money >= 15:
			if !$controls/show_shop/def.is_playing():
				$controls/show_shop/def.play("start")
			if Input.is_action_just_pressed("show_shop"):
				$controls/show_shop/def.play("end")
				shop_check = true
	if not reload_check:
		if weapons_enabled["pistol"] == 1 or weapons_enabled["uzi"] == 1 or weapons_enabled["shotgun"] == 1:
			$controls/reload/def.play("start_end")
			reload_check = true
	if not ranking_check:
		if GlobalSceneScript.combo >= 50:
			$controls/ranking/def.play("start_end")
			ranking_check = true
	pass


func kill_player():
	GlobalSceneScript.main_node.get_parent().gameover()
	alive = false
	$spr.texture = load("res://sprites/mobs/player/dead.png")
	pass

func revive_player():
	$timers/revive_timer.start()
	alive = true
	$spr.texture = load("res://sprites/mobs/player/player.png")
	$revive_kill_zone.set_deferred("monitoring", true)


func tip_anim():
	$controls/tip/under_lay.text = $controls/tip.text

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	inventory()
	set_costs()
	tip_anim()
	$shop.visible = alive
	$inventory.visible = alive
	$controls.visible = alive
	GlobalSceneScript.player_position = global_position
	if alive:
		controls_check()
		if Input.is_action_just_pressed("show_shop") and !is_shop:
			$shop/base/def.play("start")
		elif Input.is_action_just_pressed("show_shop") and is_shop:
			$shop/base/def.play("end")
		if !is_shop:
			attack()
			look_at(get_global_mouse_position())
		var horiz_dir = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")) 
		var vert_dir = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		vec = Vector2(horiz_dir,vert_dir).limit_length(1)
		vec = vec*(speed+int(Input.is_action_pressed("sprint"))*run_speed_ad)*delta
		vec = move_and_slide(vec)
	pass


func _input(event):
	if alive:
		if event.as_text().is_valid_integer():
			if int(event.as_text()) > 0 and int(event.as_text()) < 5:
				change_weapon(int(event.as_text()))
		for i in range(1, 5):
			if str(i) in event.as_text() and "Shift" in event.as_text():
				change_weapon(i)

func change_weapon(weapon_id):
	for i in range(0, $inventory/base.get_child_count()):
		$inventory/base.get_child(i).get_child(0).modulate = Color.white
	var weapon_list=["bat", "pistol", "uzi", "shotgun"]
	if weapons_enabled[weapon_list[weapon_id-1]] == 1:
		current_weapon = weapon_id-1
		get_node("inventory/base/"+weapon_list[weapon_id-1]+"/lbl").modulate = Color.red
	pass


func attack():
	$weapons/bat.visible = current_weapon == 0
	$weapons/pistol.visible = current_weapon == 1
	$weapons/uzi.visible = current_weapon == 2
	$weapons/shotgun.visible = current_weapon == 3
	if current_weapon == 0:
		if is_able_bat:
			if Input.is_action_just_pressed("LMB"):
				is_able_bat = false
				$weapons/bat/attacks.play("attack"+str(bat_state))
				$timers/bat_timer.start(bat_shoot_cd)
				var bat_hit = bat_hit_scene.instance()
				bat_hit.damage = bat_damage
				bat_hit.state = bat_state
				bat_hit.global_position = $weapons/bat.global_position
				bat_hit.global_rotation = global_rotation
				if GlobalSceneScript.main_node:
					GlobalSceneScript.main_node.add_child(bat_hit)
				bat_state = fmod(bat_state+1,3)
				bat_state += int(bat_state == 0)
	if current_weapon == 1:
		if is_able_to_shoot_pistol and pistol_current_ammo >= 1:
			if Input.is_action_just_pressed("LMB"):
				emit_bullet_shell()
				$weapons/pistol/sounds/shoot.play()
				is_able_to_shoot_pistol = false
				$weapons/pistol/attack.play("attack")
				$timers/pistol_cd_timer.start(pistol_shoot_cd)
				$timers/pistol_reload_timer.start(pistol_reload_cd)
				pistol_current_ammo -= 1
				var pistol_bullet = pistol_bullet_scene.instance()
				pistol_bullet.damage = pistol_damage
				pistol_bullet.penetration = pistol_penetration
				pistol_bullet.global_position = $weapons/pistol/emit_point.global_position
				pistol_bullet.global_rotation = global_rotation
				pistol_bullet.speed = 500
				pistol_bullet.vec = global_position.direction_to($weapons/pistol.global_position)
				pistol_bullet.vec = count_spread(pistol_bullet.vec, pistol_spread)
				if GlobalSceneScript.main_node:
					GlobalSceneScript.main_node.add_child(pistol_bullet)
	if current_weapon == 2:
		if is_able_to_shoot_uzi and uzi_current_ammo >= 1:
			if Input.is_action_pressed("LMB"):
				$weapons/uzi/sounds/shoot.play()
				emit_bullet_shell()
				is_able_to_shoot_uzi = false
				$weapons/uzi/attack.play("attack")
				$timers/uzi_cd_timer.start(uzi_shoot_cd)
				$timers/uzi_reload_timer.start(uzi_reload_cd)
				uzi_current_ammo -= 1
				var uzi_bullet = pistol_bullet_scene.instance()
				uzi_bullet.damage = uzi_damage
				uzi_bullet.penetration = uzi_penetration
				uzi_bullet.global_position = $weapons/uzi/emit_point.global_position
				uzi_bullet.global_rotation = global_rotation
				uzi_bullet.speed = 500
				uzi_bullet.vec = global_position.direction_to($weapons/uzi.global_position)
				uzi_bullet.vec = count_spread(uzi_bullet.vec, uzi_spread)
				if GlobalSceneScript.main_node:
					GlobalSceneScript.main_node.add_child(uzi_bullet)
	if current_weapon == 3:
		if is_able_to_shoot_shotgun and shotgun_current_ammo >= 1:
			if Input.is_action_just_pressed("LMB"):
				is_able_to_shoot_shotgun = false
				$weapons/shotgun/sounds/shoot.play()
				$weapons/shotgun/attack.play("attack")
				$timers/shotgun_cd_timer.start(shotgun_shoot_cd)
				$timers/shotgun_reload_timer.start(shotgun_reload_cd)
				shotgun_current_ammo -= 1
				for i in range(0, shotgun_pelets):
					var shotgun_bullet = shotgun_bullet_scene.instance()
					shotgun_bullet.damage = shotgun_damage
					shotgun_bullet.penetration = shotgun_penetration
					shotgun_bullet.global_position = $weapons/shotgun/emit_point.global_position
					shotgun_bullet.global_rotation = global_rotation
					shotgun_bullet.speed = 500
					shotgun_bullet.vec = global_position.direction_to($weapons/shotgun.global_position)
					shotgun_bullet.vec = count_spread(shotgun_bullet.vec, shotgun_spread)
					if GlobalSceneScript.main_node:
						GlobalSceneScript.main_node.add_child(shotgun_bullet)



func emit_bullet_shell():
	if current_weapon == 1:
		var shell = bullet_shell_scene.instance()
		shell.global_position = $weapons/pistol/shell_point.global_position
		shell.vec = $weapons/pistol/shell_point.global_position.direction_to($weapons/pistol/shell_point_normal.global_position)
		shell.vec = shell.vec * rand_range(500, 1000)
		GlobalSceneScript.add_child(shell)
	if current_weapon == 2:
		var shell = bullet_shell_scene.instance()
		shell.global_position = $weapons/uzi/shell_point.global_position
		shell.vec = $weapons/uzi/shell_point.global_position.direction_to($weapons/uzi/shell_point_normal.global_position)
		shell.vec = shell.vec * rand_range(500, 1000)
		GlobalSceneScript.add_child(shell)


func emit_shotgun_shell():
	var shell = shotgun_shell_scene.instance()
	shell.global_position = $weapons/shotgun/shell_point.global_position
	shell.vec = $weapons/shotgun/shell_point.global_position.direction_to($weapons/shotgun/shell_point_normal.global_position)
	shell.vec = shell.vec * rand_range(200, 700)
	GlobalSceneScript.add_child(shell)


func count_spread(in_vec,in_spread):
	return in_vec + Vector2(rand_range(-1,1)*(in_spread/100),rand_range(-1,1)*(in_spread/100))


func _on_bat_timer_timeout():
	is_able_bat = true
	pass # Replace with function body.


func _on_pistol_cd_timer_timeout():
	is_able_to_shoot_pistol = true
	pass # Replace with function body.


func _on_pistol_reload_timer_timeout():
	$weapons/pistol/sounds/reload.play()
	pistol_current_ammo = pistol_max_ammo
	pass # Replace with function body.


func _on_uzi_cd_timer_timeout():
	is_able_to_shoot_uzi = true
	pass # Replace with function body.




func _on_uzi_reload_timer_timeout():
	$weapons/uzi/sounds/reload.play()
	uzi_current_ammo = uzi_max_ammo
	pass # Replace with function body.


func _on_shotgun_cd_timer_timeout():
	is_able_to_shoot_shotgun = true
	pass # Replace with function body.


func _on_shotgun_reload_timer_timeout():
	$weapons/shotgun/sounds/reload.play()
	shotgun_current_ammo += 1
	shotgun_current_ammo = clamp(shotgun_current_ammo, 0 , shotgun_max_ammo)
	if shotgun_current_ammo != shotgun_max_ammo:
		$timers/shotgun_reload_timer.start(shotgun_reload_cd)
	pass # Replace with function body.


func _on_bat_cd_upgrade_pressed():
	if GlobalSceneScript.money >= 15*(1.5-bat_shoot_cd) and bat_shoot_cd > 0.1:
		GlobalSceneScript.money -= 15*(1.5-bat_shoot_cd)
		bat_shoot_cd -= 0.1
	pass # Replace with function body.


func _on_bat_dmg_upgrade_pressed():
	if GlobalSceneScript.money >= 30*(bat_damage/10-4):
		GlobalSceneScript.money -= 30*(bat_damage/10-4)
		bat_damage += 10
	pass # Replace with function body.


func _on_buy_pistol_pressed():
	if GlobalSceneScript.money >= 100:
		GlobalSceneScript.money -= 100
		var pickable = pickable_weapon_tscn.instance()
		pickable.global_position = global_position + Vector2(rand_range(-1000,1000),rand_range(-1000,1000))
		pickable.weapon = "pistol"
		GlobalSceneScript.main_node.add_child(pickable)
	pass # Replace with function body.


func _on_pistol_cd_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(1.1-pistol_shoot_cd) and pistol_shoot_cd > 0.01:
		GlobalSceneScript.money -= 20*(1.1-pistol_shoot_cd)
		pistol_shoot_cd -= 0.01
	pass # Replace with function body.



func _on_pistol_dmg_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(pistol_damage/10-4) and pistol_damage < 100:
		GlobalSceneScript.money -= 20*(pistol_damage/10-4)
		pistol_damage += 10
	pass # Replace with function body.


func _on_pistol_penetration_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(pistol_penetration-1+1):
		GlobalSceneScript.money -= 20*(pistol_penetration-1+1)
		pistol_penetration += 1
	pass # Replace with function body.


func _on_pistol_reload_upgrade_pressed():
	if GlobalSceneScript.money >= 10*(6.0-pistol_reload_cd) and pistol_reload_cd > 1.8:
		GlobalSceneScript.money -= 10*(6.0-pistol_reload_cd)
		pistol_reload_cd -= 0.2
	pass # Replace with function body.


func _on_pistol_accuracy_upgrade_pressed():
	if GlobalSceneScript.money >= 5*(31-pistol_spread) and pistol_spread > 0:
		GlobalSceneScript.money -= 5*(31-pistol_spread)
		pistol_spread -= 0.2
	pass # Replace with function body.


func _on_uzi_buy_pressed():
	if GlobalSceneScript.money >= 200:
		GlobalSceneScript.money -= 200
		var pickable = pickable_weapon_tscn.instance()
		pickable.global_position = global_position + Vector2(rand_range(-1000,1000),rand_range(-1000,1000))
		pickable.weapon = "uzi"
		GlobalSceneScript.main_node.add_child(pickable)
	pass # Replace with function body.


func _on_uzi_cd_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(1.05-uzi_shoot_cd) and uzi_shoot_cd > 0.01:
		GlobalSceneScript.money -= 20*(1.05-uzi_shoot_cd)
		uzi_shoot_cd -= 0.01
	pass # Replace with function body.


func _on_uzi_dmg_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(uzi_damage/10-4) and uzi_damage < 100:
		GlobalSceneScript.money -= 20*(uzi_damage/10-4)
		uzi_damage += 10
	pass # Replace with function body.


func _on_uzi_penetration_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(uzi_penetration-1+1):
		GlobalSceneScript.money -= 20*(uzi_penetration-1+1)
		uzi_penetration += 1
	pass # Replace with function body.


func _on_uzi_reload_upgrade_pressed():
	if GlobalSceneScript.money >= 10*(6.0-uzi_reload_cd) and uzi_reload_cd>2.2:
		GlobalSceneScript.money -= 10*(6.0-uzi_reload_cd)
		uzi_reload_cd -= 0.2
	pass # Replace with function body.


func _on_uzi_accuracy_upgrade_pressed():
	if GlobalSceneScript.money >= 5*(46-uzi_spread) and uzi_spread > 0:
		GlobalSceneScript.money -= 5*(46-uzi_spread)
		uzi_spread -= 0.2
	pass # Replace with function body.


func _on_shotgun_buy_pressed():
	if GlobalSceneScript.money >= 300 and $shop/base/shotgun/buy/lbl.text == "WEAPON_BUY":
		GlobalSceneScript.money -= 300
		$shop/base/shotgun/buy/lbl.text = "WEAPON_CLIP"
		var pickable = pickable_weapon_tscn.instance()
		pickable.global_position = global_position + Vector2(rand_range(-1000,1000),rand_range(-1000,1000))
		pickable.weapon = "shotgun"
		GlobalSceneScript.main_node.add_child(pickable)
	elif GlobalSceneScript.money >= 5*(shotgun_max_ammo - 5) and $shop/base/shotgun/buy/lbl.text == "WEAPON_CLIP":
		GlobalSceneScript.money -= 5*(shotgun_max_ammo - 5)
		shotgun_max_ammo += 1
	pass # Replace with function body.


func _on_shotgun_dmg_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(shotgun_damage/10-2) and shotgun_damage < 100:
		GlobalSceneScript.money -= 20*(shotgun_damage/10-2)
		shotgun_damage += 10
	pass # Replace with function body.


func _on_shotgun_penetration_upgrade_pressed():
	if GlobalSceneScript.money >= 20*(shotgun_penetration-1+1):
		GlobalSceneScript.money -= 20*(shotgun_penetration-1+1)
		shotgun_penetration += 1
	pass # Replace with function body.


func _on_shotgun_reload_upgrade_pressed():
	if GlobalSceneScript.money >= 10*(3.0-shotgun_reload_cd) and shotgun_reload_cd > 1.2:
		GlobalSceneScript.money -= 10*(3.0-shotgun_reload_cd)
		shotgun_reload_cd -= 0.2
	pass # Replace with function body.


func _on_shotgun_accuracy_upgrade_pressed():
	if GlobalSceneScript.money >= 2*(61-shotgun_spread) and shotgun_spread > 0:
		GlobalSceneScript.money -= 2*(61-shotgun_spread)
		shotgun_spread -= 0.2
	pass # Replace with function body.


func _on_pistol_max_ammo_upgrade_pressed():
	if GlobalSceneScript.money >= 10*(pistol_max_ammo-11):
		GlobalSceneScript.money -= 10*(pistol_max_ammo-11)
		pistol_max_ammo += 1
	pass # Replace with function body.


func _on_uzi_max_ammo_upgrade_pressed():
	if GlobalSceneScript.money >= 1*(uzi_max_ammo-29):
		GlobalSceneScript.money -= 1*(uzi_max_ammo-29)
		uzi_max_ammo += 1
	pass # Replace with function body.


func set_costs():
	$shop/base/bat/cd_upgrade/cost.text = str(15*(1.5-bat_shoot_cd))
	$shop/base/bat/dmg_upgrade/cost.text = str(30*(bat_damage/10-4))
	#PISTOL
	$shop/base/pistol/buy.visible = weapons_enabled["pistol"] != 1
	$shop/base/pistol/accuracy/cost.text = str(5*(31-pistol_spread))
	$shop/base/pistol/buy/cost.text = str(100)
	$shop/base/pistol/cd_upgrade/cost.text = str(20*(1.1-pistol_shoot_cd))
	$shop/base/pistol/dmg_upgrade/cost.text = str(20*(pistol_damage/10-4))
	$shop/base/pistol/penetration/cost.text = str(20*(pistol_penetration-1+1))
	$shop/base/pistol/reload/cost.text = str(10*(6.0-pistol_reload_cd))
	$shop/base/pistol/max_ammo_upgrade/cost.text = str(10*(pistol_max_ammo-11))
	#UZI
	$shop/base/uzi/buy.visible = weapons_enabled["uzi"] != 1
	$shop/base/uzi/buy/cost.text = str(200)
	$shop/base/uzi/cd_upgrade/cost.text = str(20*(1.05-uzi_shoot_cd))
	$shop/base/uzi/dmg_upgrade/cost.text = str(20*(uzi_damage/10-4))
	$shop/base/uzi/penetration/cost.text = str(20*(uzi_penetration-1+1))
	$shop/base/uzi/reload/cost.text = str(10*(6.0-uzi_reload_cd))
	$shop/base/uzi/accuracy/cost.text = str(5*(46-uzi_spread))
	$shop/base/uzi/max_ammo_upgrade/cost.text = str(1*(uzi_max_ammo-29))
	#SHOTGUN
	if weapons_enabled["shotgun"] == 1:
		$shop/base/shotgun/buy/cost.text = str(5*(shotgun_max_ammo - 5))
	else:
		$shop/base/shotgun/buy/cost.text = str(300)
	$shop/base/shotgun/dmg_upgrade/cost.text = str(20*(shotgun_damage/10-2))
	$shop/base/shotgun/penetration/cost.text = str(20*(shotgun_penetration-1+1))
	$shop/base/shotgun/reload/cost.text = str(10*(3.0-shotgun_reload_cd))
	$shop/base/shotgun/accuracy/cost.text = str(2*(61-shotgun_spread))
	pass



func inventory():
	# EQUIPING
	$inventory/base/bat.visible = weapons_enabled["bat"] == 1
	$inventory/base/pistol.visible = weapons_enabled["pistol"] == 1
	$inventory/base/uzi.visible = weapons_enabled["uzi"] == 1
	$inventory/base/shotgun.visible = weapons_enabled["shotgun"] == 1
	# COOL DOWN
	$inventory/base/bat/t_spr.max_value = bat_shoot_cd
	$inventory/base/bat/t_spr.value = (bat_shoot_cd-$timers/bat_timer.time_left)
	$inventory/base/pistol/cd_spr.max_value = pistol_shoot_cd
	$inventory/base/pistol/cd_spr.value = pistol_shoot_cd - $timers/pistol_cd_timer.time_left
	$inventory/base/uzi/cd_spr.max_value = uzi_shoot_cd
	$inventory/base/uzi/cd_spr.value = uzi_shoot_cd - $timers/uzi_cd_timer.time_left
	$inventory/base/shotgun/cd_spr.max_value = shotgun_shoot_cd
	$inventory/base/shotgun/cd_spr.value = shotgun_shoot_cd - $timers/shotgun_cd_timer.time_left
	# RELOAD
	$inventory/base/pistol/reload_spr.max_value = pistol_reload_cd
	$inventory/base/pistol/reload_spr.value = pistol_reload_cd - $timers/pistol_reload_timer.time_left
	$inventory/base/uzi/reload_spr.max_value = uzi_reload_cd
	$inventory/base/uzi/reload_spr.value = uzi_reload_cd - $timers/uzi_reload_timer.time_left
	$inventory/base/shotgun/reload_spr.max_value = shotgun_reload_cd
	$inventory/base/shotgun/reload_spr.value = shotgun_reload_cd - $timers/shotgun_reload_timer.time_left
	# AMMO
	$inventory/base/pistol/ammo.text = str(pistol_current_ammo)
	$inventory/base/uzi/ammo.text = str(uzi_current_ammo)
	$inventory/base/shotgun/ammo.text = str(shotgun_current_ammo)


func _on_revive_timer_timeout():
	$revive_kill_zone.set_deferred("monitoring", false)
	pass # Replace with function body.


func _on_revive_kill_zone_body_entered(body):
	if body.has_method("enemy"):
		body.damage(body.lives)
	pass # Replace with function body.
