extends Node2D

var next_scene = null

var player_location = Vector2(0, 0)
var player_direction = Vector2(0, 0)

enum TransitionType { NEW_SCENE, PARTY_SCREEN, MENU_ONLY, BATTLE }
var transition_type = TransitionType.NEW_SCENE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
#菜单有关切换功能
func transition_to_party_screen():
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN
	
func transition_exit_party_screen():
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY

#世界场景切换
func transition_to_scene(new_scene: String, spawn_location, spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = TransitionType.NEW_SCENE
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")

#战斗场景切换
func transition_to_battle(new_scene: String):
	next_scene = new_scene
	transition_type = TransitionType.BATTLE
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")




#结束场景切换动画以后的新场景载入
func finished_fading():
	match transition_type:
		TransitionType.NEW_SCENE:
			$CurrentScene.get_child(0).queue_free()
			$CurrentScene.add_child(load(next_scene).instance())
			
			var player = get_node("/root/Game/SceneManager/CurrentScene").get_children().back().find_node("Player")
			player.set_spawn(player_location, player_direction)
		TransitionType.PARTY_SCREEN:
			$Menu.load_party_screen()
		TransitionType.MENU_ONLY:
			$Menu.unload_party_screen()
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")
