extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$money.text = tr("LBL_MONEY:") + str(GlobalSceneScript.money)
	$score.text = tr("LBL_SCORE:")+ str(GlobalSceneScript.score)
	$combo.text = "x"+str(GlobalSceneScript.combo)
	$ranks.visible = GlobalSceneScript.combo > 0
	if GlobalSceneScript.combo >= 0:
		$ranks.play("D")
	if GlobalSceneScript.combo >= 20:
		$ranks.play("C")
	if GlobalSceneScript.combo >= 30:
		$ranks.play("B")
	if GlobalSceneScript.combo >= 40:
		$ranks.play("A")
	if GlobalSceneScript.combo >= 50:
		$ranks.play("ZZZ")
	pass
